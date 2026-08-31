class Farm {
  const Farm({
    required this.id,
    required this.name,
    this.location,
    this.inviteCode,
    this.motherPigCount = 0,
    this.subscriptionPlan,
  });

  final String id;
  final String name;
  final String? location;
  final String? inviteCode;
  final int motherPigCount;
  final String? subscriptionPlan;
}
