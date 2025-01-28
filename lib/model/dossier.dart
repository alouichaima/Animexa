class Dossier {
  final String posologie;
  final String medicaments;

  Dossier({
    required this.posologie,
    required this.medicaments,
  });

  
  Map<String, dynamic> toJson() {
    return {
      'posologie': posologie,
      'medicaments': medicaments,
    };
  }

 
  factory Dossier.fromMap(Map<String, dynamic> map) {
    return Dossier(
      posologie: map['posologie'] as String,
      medicaments: map['medicaments'] as String,
    );
  }
}
