class Pregnancy {
  const Pregnancy({
    required this.id,
    required this.sowId,
    required this.matingDate,
    required this.expectedFarrowingDate,
    required this.status,
    this.sowTag,
    this.boarId,
    this.boarTag,
    this.confirmationDate,
    this.actualFarrowingDate,
    this.expectedLitterSize,
    this.bornAlive,
    this.stillborn,
    this.mummified,
    this.weaned,
    this.notes,
    this.daysUntilFarrowing,
  });

  final String id;
  final String sowId;
  final String? sowTag;
  final String? boarId;
  final String? boarTag;
  final DateTime matingDate;
  final DateTime? confirmationDate;
  final DateTime expectedFarrowingDate;
  final DateTime? actualFarrowingDate;
  final String status;
  final int? expectedLitterSize;
  final int? bornAlive;
  final int? stillborn;
  final int? mummified;
  final int? weaned;
  final String? notes;
  final int? daysUntilFarrowing;

  bool get isOverdue =>
      status != 'farrowed' &&
      status != 'aborted' &&
      (daysUntilFarrowing ?? 0) < 0;

  bool get isDueSoon =>
      status != 'farrowed' &&
      status != 'aborted' &&
      (daysUntilFarrowing ?? 999) >= 0 &&
      (daysUntilFarrowing ?? 999) <= 14;
}
