class Farm {
  const Farm({
    required this.id,
    required this.name,
    this.location,
    this.inviteCode,
  });

  final String id;
  final String name;
  final String? location;
  final String? inviteCode;
}
