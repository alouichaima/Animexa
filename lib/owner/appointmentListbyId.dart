import 'package:animexa/owner/BasePage.dart';
import 'package:animexa/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../model/appointment.dart';

class AppointmentListById extends BasePage {
  const AppointmentListById({super.key})
      : super(
          body: const _AppointmentListByIdContent(),
          currentIndex: 1, 
        );
}

class _AppointmentListByIdContent extends StatefulWidget {
  const _AppointmentListByIdContent();

  @override
  State<_AppointmentListByIdContent> createState() =>
      _AppointmentListByIdContentState();
}

class _AppointmentListByIdContentState
    extends State<_AppointmentListByIdContent> {
  final NotificationService _notificationService = NotificationService();

  final TextEditingController searchController = TextEditingController();
  List<Appointment> appointments = [];
  List<Appointment> filteredAppointments = [];
  bool isLoading = true;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;


  Stream<List<Appointment>> _getUserAppointments() {
    final firestore = FirebaseFirestore.instance;

    return firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  // Check for upcoming appointments and schedule reminder
  void _checkForUpcomingAppointments() {
    for (var appointment in appointments) {
      if (appointment.date != null) {
        try {
          DateTime appointmentDate;

          
          try {
            appointmentDate =
                DateFormat('yyyy-MM-dd').parse(appointment.date.toString());
          } catch (e) {
            
            try {
              appointmentDate =
                  DateFormat('d MMMM yyyy').parse(appointment.date.toString());
            } catch (e) {
              print("Error parsing appointment date: ${appointment.date}");
              continue; 
            }
          }

          
          DateTime reminderDate =
              appointmentDate.subtract(const Duration(days: 2));

          
          if (DateTime.now().isAfter(reminderDate) &&
              DateTime.now().isBefore(appointmentDate)) {
            
            _notificationService.scheduleAppointmentReminder(
              appointmentDate,
              appointment.veterinarian['username'],
            );
          }
        } catch (e) {
          print("Error in _checkForUpcomingAppointments: $e");
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserAppointments().listen((data) {
      setState(() {
        appointments = data;
        filteredAppointments = appointments;
        isLoading = false;
      });
      _checkForUpcomingAppointments(); 
    });

    searchController.addListener(_filterAppointments);
  }

  void _filterAppointments() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredAppointments = appointments.where((appointment) {
        return appointment.veterinarian['username']
                ?.toLowerCase()
                .contains(query) ??
            false;
      }).toList();
    });
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('appointments').doc(appointmentId).delete();
      setState(() {
        appointments.removeWhere((appt) => appt.id == appointmentId);
        filteredAppointments = List.from(appointments);
      });
      print('Appointment deleted successfully');
    } catch (e) {
      print('Failed to delete appointment: $e');
    }
  }

  Future<void> _updateAppointment(
      BuildContext context, Appointment appointment) async {
    final TextEditingController dateController =
        TextEditingController(text: appointment.date);
    final TextEditingController timeController =
        TextEditingController(text: appointment.time);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Picker
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(dateController.text) ??
                        DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    final formattedDate =
                        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                    dateController.text =
                        formattedDate; 
                  }
                },
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final firestore = FirebaseFirestore.instance;
                try {
                  await firestore
                      .collection('appointments')
                      .doc(appointment.id)
                      .update({
                    'date': dateController.text,
                    'time': timeController.text,
                  });

                  setState(() {
                    
                    appointment.date = dateController.text;
                    appointment.time = timeController.text;
                  });

                  Navigator.pop(context);
                  print('Appointment updated successfully');
                } catch (e) {
                  print('Failed to update appointment: $e');
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_filterAppointments);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by veterinarian name',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredAppointments.isEmpty
                  ? const Center(
                      child: Text(
                        'No appointments found.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = filteredAppointments[index];
                        final imageUrl =
                            appointment.veterinarian['profileImageUrl'] ?? '';

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  )
                                : const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.person),
                                  ),
                            title: Text(
                              'Appointment with ${appointment.veterinarian['username']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${appointment.date}'),
                                Text('Time: ${appointment.time}'),
                                Text('Contact: ${appointment.number}'),
                              ],
                            ),
                            trailing: Wrap(
                              spacing: 8, 
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _updateAppointment(context, appointment),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteAppointment(appointment.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
