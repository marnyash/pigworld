class Farm {
  const Farm({
    required this.id,
    required this.name,
    this.location,
    this.inviteCode,
    this.motherPigCount = 0,
    this.registeredPigletCount = 0,
    this.pregnantPigCount = 0,
    this.subscriptionPlan,
  });

  final String id;
  final String name;
  final String? location;
  final String? inviteCode;
  final int motherPigCount;
  final int registeredPigletCount;
  final int pregnantPigCount;
  final String? subscriptionPlan;

  int get registeredHerdCount => motherPigCount + registeredPigletCount;
}
