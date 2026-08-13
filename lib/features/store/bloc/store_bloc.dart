import 'package:flutter/material.dart';

import 'package:edu_play/core/analytics/analytics_service.dart';
import 'package:edu_play/data/datasources/student_datasource.dart'
    show PurchaseResult;
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/features/store/services/store_catalog_cache.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/utils/injection_container.dart';

/// Category-ish filters for the Tienda catalog grid — the first three mirror
/// [StoreCategory] 1:1, the last two ("pro", "owned") cut across categories.
enum StoreFilter { all, avatarColor, avatarIcon, sticker, pro, owned }

/// Result of [StoreBloc.purchase] — distinct from [PurchaseResult] because
/// the UI reacts very differently to "bought it" vs. "sent to your parents
/// for approval" even though both are non-error outcomes.
enum PurchaseOutcome { success, pendingApproval, failed }

/// UI state for the Tienda tab. Deliberately holds no profile data of its
/// own — [dashboardBloc] is already loaded by the time `TiendaView` can be
/// reached (it's a tab inside the student dashboard), so points/inventory
/// are read straight from it and `refresh()` after a purchase/equip keeps
/// both the store and the rest of the dashboard (points badge, sticker
/// album) in sync from one source of truth.
class StoreBloc extends ChangeNotifier {
  StoreBloc({required this.dashboardBloc}) {
    _catalogCache.addListener(notifyListeners);
    _catalogCache.ensureLoaded();
  }

  final StudentDashboardBloc dashboardBloc;
  final StudentRepository _studentRepository = sl<StudentRepository>();
  final StoreCatalogCache _catalogCache = sl<StoreCatalogCache>();

  bool isBusy = false;
  String? lastError;
  String? lastInfo;

  StoreFilter filter = StoreFilter.all;

  void setFilter(StoreFilter value) {
    if (filter == value) return;
    filter = value;
    notifyListeners();
  }

  /// False until the catalog cache's first [StoreCatalogCache.ensureLoaded]
  /// resolves — the Tienda shows a spinner instead of the grid until then,
  /// since [fullCatalog] briefly holds the static seed list either way and
  /// would otherwise look "done" before Firestore has actually been tried.
  bool get catalogLoaded => _catalogCache.isLoaded;

  /// True when the live catalog couldn't be fetched from Firestore, so
  /// [fullCatalog] is the offline/static fallback rather than the
  /// admin-edited one. The Tienda shows a small "sin conexión" banner
  /// instead of failing silently — items purchasable here still work
  /// (server-side firestore.rules re-validate price/PRO against whatever
  /// the catalog document actually is), the risk is just showing stale
  /// prices/availability.
  bool get catalogHasError => _catalogCache.hasError;

  Future<void> retryCatalogLoad() => _catalogCache.refresh();

  /// Every catalog item regardless of season — used by "Mis compras" so an
  /// already-purchased seasonal item keeps showing in history after its
  /// window closes, and by the item-name/preview lookups elsewhere.
  List<StoreItem> get fullCatalog => _catalogCache.items;

  /// Full catalog, minus anything outside its seasonal availability window.
  /// This is what the shopping grid itself renders.
  List<StoreItem> get availableCatalog =>
      fullCatalog.where((i) => i.isAvailableAt(DateTime.now())).toList();

  List<StoreItem> get featuredItems =>
      availableCatalog.where((i) => i.isFeatured).toList();

  List<StoreItem> filterItems(List<StoreItem> items) {
    switch (filter) {
      case StoreFilter.all:
        return items;
      case StoreFilter.avatarColor:
        return items.where((i) => i.category == StoreCategory.avatarColor).toList();
      case StoreFilter.avatarIcon:
        return items.where((i) => i.category == StoreCategory.avatarIcon).toList();
      case StoreFilter.sticker:
        return items.where((i) => i.category == StoreCategory.sticker).toList();
      case StoreFilter.pro:
        return items.where(isProOnly).toList();
      case StoreFilter.owned:
        return items.where(isOwned).toList();
    }
  }

  int get points => dashboardBloc.points;

  bool isOwned(StoreItem item) => dashboardBloc.ownedItemIds.contains(item.id);

  bool isPending(StoreItem item) =>
      dashboardBloc.pendingPurchaseItemIds.contains(item.id);

  bool isProOnly(StoreItem item) => dashboardBloc.isProOnlyItem(item);

  bool isLevelLocked(StoreItem item) => dashboardBloc.isLevelLocked(item);

  bool canAccess(StoreItem item) => dashboardBloc.canAccessItem(item);

  bool get guestLimitReached =>
      dashboardBloc.isGuest && !dashboardBloc.hasGuestPurchasesRemaining;

  int get guestPurchasesRemaining => dashboardBloc.guestPurchasesRemaining;

  bool get requiresApproval => dashboardBloc.requiresPurchaseApproval;

  bool get spendLimitEnabled => dashboardBloc.spendLimitEnabled;

  int get spendLimitRemaining => dashboardBloc.spendLimitRemaining;

  /// True if buying [item] right now would push spend within the current
  /// window over the parent-configured limit. Distinct from "reached",
  /// which only covers the case where the limit was already hit — this
  /// also blocks a single purchase big enough to blow past it in one go.
  bool wouldExceedSpendLimit(StoreItem item) {
    if (!spendLimitEnabled) return false;
    return dashboardBloc.spentInWindow + item.cost >
        dashboardBloc.spendLimitAmount;
  }

  DateTime? purchaseDateFor(StoreItem item) =>
      dashboardBloc.purchaseDates[item.id];

  bool canPurchase(StoreItem item) {
    if (isOwned(item)) return false;
    if (isPending(item)) return false;
    if (!canAccess(item)) return false;
    if (guestLimitReached) return false;
    if (wouldExceedSpendLimit(item)) return false;
    return points >= item.cost;
  }

  bool isEquipped(StoreItem item) {
    switch (item.category) {
      case StoreCategory.avatarColor:
        return dashboardBloc.equippedAvatarColorHex == item.colorHex;
      case StoreCategory.avatarIcon:
        return dashboardBloc.equippedAvatarIcon == item.id;
      case StoreCategory.sticker:
        return false; // stickers have no equip slot — owning is the reward
    }
  }

  Future<PurchaseOutcome> purchase(StoreItem item) async {
    if (isBusy) return PurchaseOutcome.failed;
    if (!canAccess(item)) {
      final reason = isLevelLocked(item) ? 'level_locked' : 'pro_required';
      if (isProOnly(item) && !isLevelLocked(item)) {
        AnalyticsService.logStoreProAttempt(item.id);
      }
      AnalyticsService.logStorePurchaseBlocked(item.id, reason);
      lastError = isLevelLocked(item)
          ? 'Este artículo se desbloquea en el nivel ${item.minLevel}.'
          : 'Los stickers exclusivos son solo para usuarios PRO.';
      notifyListeners();
      return PurchaseOutcome.failed;
    }
    if (guestLimitReached) {
      AnalyticsService.logStoreGuestLimitReached();
      lastError = 'Ya probaste 3 productos. Regístrate para seguir comprando.';
      notifyListeners();
      return PurchaseOutcome.failed;
    }
    if (wouldExceedSpendLimit(item)) {
      AnalyticsService.logStorePurchaseBlocked(item.id, 'spend_limit');
      final period =
          dashboardBloc.spendLimitPeriod.windowDays == 1 ? 'hoy' : 'esta semana';
      lastError =
          'Tus papás pusieron un límite de gasto y ya usaste ${dashboardBloc.spentInWindow} de ${dashboardBloc.spendLimitAmount} pts $period.';
      notifyListeners();
      return PurchaseOutcome.failed;
    }
    isBusy = true;
    lastError = null;
    lastInfo = null;
    notifyListeners();

    final PurchaseResult result;
    if (dashboardBloc.isGuest) {
      result = await dashboardBloc.purchaseGuestItem(item);
    } else if (requiresApproval) {
      result = await dashboardBloc.requestPurchaseItem(item);
    } else {
      result = await _studentRepository.purchaseItem(
        studentId: dashboardBloc.myStudentId,
        itemId: item.id,
        itemName: item.name,
        cost: item.cost,
      );
    }

    PurchaseOutcome outcome;
    switch (result) {
      case PurchaseResult.success:
        await dashboardBloc.refresh();
        AnalyticsService.logStorePurchaseSuccess(item.id, pending: false);
        outcome = PurchaseOutcome.success;
      case PurchaseResult.pendingApproval:
        lastInfo =
            'Enviamos tu solicitud a tus papás. Verás el artículo aquí cuando la aprueben.';
        AnalyticsService.logStorePurchaseSuccess(item.id, pending: true);
        outcome = PurchaseOutcome.pendingApproval;
      case PurchaseResult.alreadyOwned:
        lastError = 'Ya tienes este artículo.';
        outcome = PurchaseOutcome.failed;
      case PurchaseResult.insufficientPoints:
        lastError = 'Todavía no te alcanzan los puntos.';
        outcome = PurchaseOutcome.failed;
      case PurchaseResult.spendLimitReached:
        lastError = 'Alcanzaste el límite de gasto que pusieron tus papás.';
        outcome = PurchaseOutcome.failed;
      case PurchaseResult.levelLocked:
        lastError = 'Todavía no alcanzas el nivel necesario para esto.';
        outcome = PurchaseOutcome.failed;
      case PurchaseResult.networkError:
        lastError = 'Sin conexión. Revisa tu internet e intenta de nuevo.';
        outcome = PurchaseOutcome.failed;
      case PurchaseResult.permissionDenied:
        lastError = 'No se pudo verificar la compra. Intenta de nuevo.';
        outcome = PurchaseOutcome.failed;
      case PurchaseResult.error:
        lastError = dashboardBloc.isGuest && guestLimitReached
            ? 'Ya probaste 3 productos. Regístrate para seguir comprando.'
            : 'No se pudo completar la compra. Intenta de nuevo.';
        outcome = PurchaseOutcome.failed;
    }

    if (outcome == PurchaseOutcome.failed) {
      AnalyticsService.logStorePurchaseBlocked(item.id, result.name);
    }

    isBusy = false;
    notifyListeners();
    return outcome;
  }

  Future<void> equip(StoreItem item) async {
    if (isBusy || item.category == StoreCategory.sticker) return;
    isBusy = true;
    notifyListeners();

    if (dashboardBloc.isGuest) {
      await dashboardBloc.equipGuestItem(item);
    } else {
      final studentId = dashboardBloc.myStudentId;
      if (item.category == StoreCategory.avatarColor) {
        await _studentRepository.equipAvatarColor(studentId, item.colorHex);
      } else {
        await _studentRepository.equipAvatarIcon(studentId, item.id);
      }
      await dashboardBloc.refresh();
    }

    isBusy = false;
    notifyListeners();
  }

  /// Reverts to the default avatar (no equipped color and/or icon).
  Future<void> unequip({bool color = false, bool icon = false}) async {
    if (isBusy) return;
    isBusy = true;
    notifyListeners();
    await dashboardBloc.unequipItem(color: color, icon: icon);
    isBusy = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _catalogCache.removeListener(notifyListeners);
    super.dispose();
  }
}
