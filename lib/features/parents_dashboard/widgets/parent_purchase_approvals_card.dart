import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/features/store/services/store_catalog_cache.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavyDark = Color(0xFF14125A);

class _PendingRequest {
  const _PendingRequest({
    required this.childId,
    required this.childName,
    required this.item,
  });
  final String childId;
  final String childName;
  final StoreItem item;
}

/// Shows Tienda purchases awaiting parent approval (see
/// `ParentQuickControls.requirePurchaseApproval`) across every child
/// profile, with inline Approve/Reject actions.
class ParentPurchaseApprovalsCard extends StatefulWidget {
  const ParentPurchaseApprovalsCard({super.key, required this.profiles});

  final List<ChildProfile> profiles;

  @override
  State<ParentPurchaseApprovalsCard> createState() =>
      _ParentPurchaseApprovalsCardState();
}

class _ParentPurchaseApprovalsCardState
    extends State<ParentPurchaseApprovalsCard> {
  final StudentRepository _studentRepository = sl<StudentRepository>();
  final StoreCatalogCache _catalogCache = sl<StoreCatalogCache>();

  List<_PendingRequest> _requests = [];
  bool _loading = true;
  String? _actingOnItemId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ParentPurchaseApprovalsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profiles != widget.profiles) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _catalogCache.ensureLoaded();
    final requests = <_PendingRequest>[];

    for (final profile in widget.profiles) {
      final data = await _studentRepository.getStudentProfile(profile.id);
      final pending = data?['pendingPurchases'] as Map?;
      if (pending == null) continue;
      for (final itemId in pending.keys) {
        final item = _catalogCache.byId(itemId as String);
        if (item == null) continue;
        requests.add(_PendingRequest(
          childId: profile.id,
          childName: profile.name,
          item: item,
        ));
      }
    }

    if (mounted) setState(() { _requests = requests; _loading = false; });
  }

  Future<void> _approve(_PendingRequest request) async {
    setState(() => _actingOnItemId = request.item.id);
    await _studentRepository.approvePendingPurchase(
      studentId: request.childId,
      itemId: request.item.id,
      itemName: request.item.name,
    );
    if (mounted) setState(() => _actingOnItemId = null);
    await _load();
  }

  Future<void> _reject(_PendingRequest request) async {
    setState(() => _actingOnItemId = request.item.id);
    await _studentRepository.rejectPendingPurchase(
      studentId: request.childId,
      itemId: request.item.id,
    );
    if (mounted) setState(() => _actingOnItemId = null);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kNavyDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_rounded, size: 16, color: Colors.white54),
              const SizedBox(width: 8),
              Text(
                'COMPRAS PENDIENTES',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              if (_requests.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6E6C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_requests.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
              ),
            )
          else if (_requests.isEmpty)
            Text(
              'No hay compras esperando tu aprobación.',
              style: GoogleFonts.nunito(color: Colors.white54, fontSize: 12),
            )
          else
            ...(_requests.map((request) {
              final busy = _actingOnItemId == request.item.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.item.name,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${request.childName} · ${request.item.cost} pts',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (busy)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                        )
                      else ...[
                        IconButton(
                          onPressed: () => _reject(request),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFFFF6E6C), size: 20),
                          tooltip: 'Rechazar',
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          onPressed: () => _approve(request),
                          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF2ECC71), size: 20),
                          tooltip: 'Aprobar',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            })),
        ],
      ),
    );
  }
}
