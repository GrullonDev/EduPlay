/// One entry in a student's spending history — written alongside every
/// completed purchase (direct or parent-approved) so "Mis compras" can show
/// a real ledger and so parent-configured spend limits can be computed by
/// summing entries within a rolling window, instead of trusting a mutable
/// running total that would drift/desync if a write were ever missed.
class PurchaseTransaction {
  const PurchaseTransaction({
    required this.itemId,
    required this.itemName,
    required this.cost,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
    this.type = PurchaseTransactionType.purchase,
  });

  factory PurchaseTransaction.fromJson(Map<String, dynamic> json) {
    return PurchaseTransaction(
      itemId: json['itemId'] as String,
      itemName: json['itemName'] as String? ?? '',
      cost: (json['cost'] as num).toInt(),
      balanceBefore: (json['balanceBefore'] as num?)?.toInt() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      type: PurchaseTransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PurchaseTransactionType.purchase,
      ),
    );
  }

  final String itemId;
  final String itemName;
  final int cost;
  final int balanceBefore;
  final int balanceAfter;
  final DateTime createdAt;
  final PurchaseTransactionType type;

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'cost': cost,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfter,
        'createdAt': createdAt.toIso8601String(),
        'type': type.name,
      };
}

enum PurchaseTransactionType { purchase, approvedPurchase, guestPurchase }
