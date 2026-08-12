import 'package:flutter/material.dart';

import 'package:edu_play/data/datasources/student_datasource.dart'
    show PurchaseResult;
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/utils/injection_container.dart';

/// UI state for the Tienda tab. Deliberately holds no profile data of its
/// own — [dashboardBloc] is already loaded by the time `TiendaView` can be
/// reached (it's a tab inside the student dashboard), so points/inventory
/// are read straight from it and `refresh()` after a purchase/equip keeps
/// both the store and the rest of the dashboard (points badge, sticker
/// album) in sync from one source of truth.
class StoreBloc extends ChangeNotifier {
  StoreBloc({required this.dashboardBloc});

  final StudentDashboardBloc dashboardBloc;
  final StudentRepository _studentRepository = sl<StudentRepository>();

  bool isBusy = false;
  String? lastError;

  int get points => dashboardBloc.points;

  bool isOwned(StoreItem item) => dashboardBloc.ownedItemIds.contains(item.id);

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

  Future<bool> purchase(StoreItem item) async {
    if (isBusy) return false;
    isBusy = true;
    lastError = null;
    notifyListeners();

    final result = await _studentRepository.purchaseItem(
      studentId: dashboardBloc.myStudentId,
      itemId: item.id,
      cost: item.cost,
    );

    switch (result) {
      case PurchaseResult.success:
        await dashboardBloc.refresh();
      case PurchaseResult.alreadyOwned:
        lastError = 'Ya tienes este artículo.';
      case PurchaseResult.insufficientPoints:
        lastError = 'Todavía no te alcanzan los puntos.';
      case PurchaseResult.error:
        lastError = 'No se pudo completar la compra. Intenta de nuevo.';
    }

    isBusy = false;
    notifyListeners();
    return result == PurchaseResult.success;
  }

  Future<void> equip(StoreItem item) async {
    if (isBusy || item.category == StoreCategory.sticker) return;
    isBusy = true;
    notifyListeners();

    final studentId = dashboardBloc.myStudentId;
    if (item.category == StoreCategory.avatarColor) {
      await _studentRepository.equipAvatarColor(studentId, item.colorHex);
    } else {
      await _studentRepository.equipAvatarIcon(studentId, item.id);
    }
    await dashboardBloc.refresh();

    isBusy = false;
    notifyListeners();
  }
}
