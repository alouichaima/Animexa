import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  String id;
  String date;
  String time;
  String userId;
  String userName;
  String number;
  Map<String, dynamic> veterinarian;
  Map<String, dynamic> additionalInfo;

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.userId,
    required this.userName,
    required this.number,
    required this.veterinarian,
    required this.additionalInfo,
  });

  
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      number: data['number'] ?? '',
      veterinarian: data['veterinarian'] ?? {},
      additionalInfo: data['additionalInfo'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'userId': userId,
      'userName': userName,
      'number': number,
      'veterinarian': veterinarian,
      'additionalInfo': additionalInfo,
    };
  }
}
