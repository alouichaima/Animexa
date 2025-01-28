class Vaccination {
  final String vaccineName;
  final DateTime dateAdministered;
  final DateTime? nextDueDate;

  Vaccination({
    required this.vaccineName,
    required this.dateAdministered,
    this.nextDueDate,
  });
  Map<String, dynamic> toJson() {
    return {
      'vaccineName': vaccineName,
      'dateAdministered': dateAdministered.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
    };
  }

 
  factory Vaccination.fromMap(Map<String, dynamic> map) {
    return Vaccination(
      vaccineName: map['vaccineName'] as String,
      dateAdministered: DateTime.parse(map['dateAdministered']),
      nextDueDate: map['nextDueDate'] != null
          ? DateTime.parse(map['nextDueDate'])
          : null,
    );
  }


}
