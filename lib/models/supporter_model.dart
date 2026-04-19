class Supporter {
  final String donorId;
  final String donorName;
  final double totalAmount;
  final bool isMonthly;
  final String? tier; // "Gold", "Silver", "Bronze"
  final DateTime lastContribution;

  Supporter({
    required this.donorId,
    required this.donorName,
    required this.totalAmount,
    required this.isMonthly,
    this.tier,
    required this.lastContribution,
  });

  String get rankTitle {
    if (isMonthly) {
      if (totalAmount >= 5000) return 'Gold Sponsor';
      if (totalAmount >= 2500) return 'Silver Sponsor';
      return 'Bronze Sponsor';
    }
    return 'Donor';
  }
}
