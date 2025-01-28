import 'package:animexa/app_route.dart';
import 'package:animexa/model/appointment.dart';
import 'package:animexa/model/user.dart';
import 'package:animexa/services/VetService.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final Map<String, List<String>> _bookedTimes = {};
  String? userName;
  String? number;
  DateTime? selectedDate;
  String? selectedTime;

  String searchName = '';
  String? selectedRegion;

  
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  static const List<String> availableTimes = [
    '10:00 AM',
    '11:00 AM',
    '1:30 PM',
    '2:30 PM',
    '3:30 PM',
  ];

  
  static const List<String> regions = [
    'Ariana',
    'Beja',
    'Ben Arous',
    'Bizerte',
    'Gabès',
    'Gafsa',
    'Jendouba',
    'Kairouan',
    'Kasserine',
    'Kébili',
    'Mahdia',
    'Manouba',
    'Medenine',
    'Monastir',
    'Nabeul',
    'Sfax',
    'Sidi Bouzid',
    'Siliana',
    'Tataouine',
    'Tozeur',
    'Tunis',
    'Zaghouan',
  ];

  

  Future<void> _selectDate(BuildContext context, LocalUser veterinarian) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;
      _showAvailableTimes(context, pickedDate, veterinarian);
    }
  }

  Future<void> _showAvailableTimes(
      BuildContext context, DateTime date, LocalUser veterinarian) async {
    final vetKey = '${veterinarian.id}_${date.toFormattedDateString()}';
    _bookedTimes.putIfAbsent(vetKey, () => []);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Available Times for ${date.toFormattedDateString()}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: availableTimes.length,
              itemBuilder: (context, index) {
                final time = availableTimes[index];
                final isBooked = _bookedTimes[vetKey]!.contains(time);
                return ListTile(
                  title: Text(time),
                  enabled: !isBooked,
                  onTap: !isBooked
                      ? () {
                          setState(() {
                            selectedTime = time;
                          });
                          Navigator.of(context).pop();
                          _confirmAppointmentDialog(context, veterinarian);
                        }
                      : null,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAppointmentDialog(
      BuildContext context, LocalUser veterinarian) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${selectedDate?.toFormattedDateString()}'),
              Text('Time: $selectedTime'),
              TextField(
                decoration: const InputDecoration(labelText: 'Your Name'),
                onChanged: (value) => userName = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Your Phone'),
                onChanged: (value) => number = value,
              ),
            ],
          ),
    actions: [
  TextButton(
    child: const Text('Reserve Appointment'),
    onPressed: () {
      if (userName?.isNotEmpty == true &&
          number?.isNotEmpty == true &&
          selectedDate != null &&
          selectedTime != null) {
        
        _bookAppointment(context, selectedDate!, selectedTime!, veterinarian);

        setState(() {
          _bookedTimes[
                  '${veterinarian.id}_${selectedDate!.toFormattedDateString()}']!
              .add(selectedTime!);
        });

        
        Navigator.of(context).pop(); 
        Navigator.pushNamed(
          context,
          '/appointmentListById', 
          arguments: {
            'appointmentId': veterinarian.id, 
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')),
        );
      }
    },
  ),

            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _bookAppointment(BuildContext context, DateTime date,
      String time, LocalUser veterinarian) async {
    final firestore = FirebaseFirestore.instance;

    String formattedDate = DateFormat('d MMMM yyyy').format(date);
    final hour = int.parse(time.split(':')[0]) % 12;
    final minute = int.parse(time.split(':')[1].split(' ')[0]);
    final isPM = time.endsWith('PM');
    String formattedTime =
        'at ${hour + (isPM ? 12 : 0)}:${minute.toString().padLeft(2, '0')}';

    final appointment = Appointment(
      id: '',
      date: formattedDate,
      time: formattedTime,
      userId: userId ?? 'unknown',
      userName: userName ?? 'unknown',
      number: number ?? 'unknown',
      veterinarian: {
        'role': veterinarian.role,
        'id': veterinarian.id,
        'username': veterinarian.username,
        'email': veterinarian.email,
        'region': veterinarian.region,
        'tel': veterinarian.tel,
        'profileImageUrl': veterinarian.profileImageUrl,
      },
      additionalInfo: {},
    );

    try {
      DocumentReference appointmentRef =
          await VeterinarianService().createAppointment(appointment.toJson());
      appointment.id = appointmentRef.id;

      await firestore
          .collection('appointments')
          .doc(appointment.id)
          .update({'id': appointment.id});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Appointment confirmed: $formattedDate $formattedTime')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create appointment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Veterinarians',
          style: TextStyle(color: Color.fromARGB(255, 20, 3, 94)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color:
              Colors.black, 
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.black),
            onPressed: () {
              Get.offAndToNamed(AppRoutes.appointmentListById);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(16.0), 
              child: Image.asset(
                'images/dogs.png', 
                height: 200, 
                width: 300, 
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by Name',
                      prefixIcon: const Icon(Icons.search), 
                      filled: true, 
                      fillColor: Colors.grey[200], 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none, 
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchName = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8.0), 
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Region', 
                      filled: true,
                      fillColor: Colors.grey[200], 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none, 
                      ),
                    ),
                    isExpanded: true,
                    value: selectedRegion,
                    items: regions.map((String region) {
                      return DropdownMenuItem<String>(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRegion = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<LocalUser>>(
              stream: VeterinarianService().getVeterinarians(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No veterinarians found.'));
                } else {
                  final veterinarians = snapshot.data!.where((veterinarian) {
                    final matchesName = veterinarian.username
                        .toLowerCase()
                        .contains(searchName);
                    final matchesRegion = selectedRegion == null ||
                        selectedRegion == 'All Regions' ||
                        veterinarian.region == selectedRegion;
                    return matchesName && matchesRegion;
                  }).toList();

                  return ListView.builder(
                    itemCount: veterinarians.length,
                    itemBuilder: (context, index) {
                      final veterinarian = veterinarians[index];
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          children: [
                            
                            CircleAvatar(
                              radius:
                                  40, 
                              backgroundImage: NetworkImage(
                                veterinarian.profileImageUrl ??
                                    'default_image_url',
                              ),
                              backgroundColor: Colors.grey[200],
                            ),
                            const SizedBox(
                                width: 16.0), // Space between image and text
                            Expanded(
                              
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    veterinarian.username,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 41, 40, 43),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.email,
                                          color: Color.fromARGB(255, 0, 0, 0), 
                                        ),
                                        const SizedBox(width: 4.0), 
                                        const Text(
                                          'Email: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                        ),
                                        Text(
                                          veterinarian.email,
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on, 
                                        color: Color.fromARGB(255, 0, 0,
                                            0), // Match the color of the text
                                      ),
                                      const SizedBox(
                                          width:
                                              4.0), // Space between icon and text
                                      const Text(
                                        'Region: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ),
                                      Text(veterinarian
                                          .region), // Display the region without special styling
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone, 
                                        color: Color.fromARGB(255, 0, 0,
                                            0), // Match the color of the text
                                      ),
                                      const SizedBox(
                                          width:
                                              4.0), // Space between icon and text
                                      const Text(
                                        'Tel: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ),
                                      Text(veterinarian
                                          .tel), // Display the telephone number without special styling
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () =>
                                  _selectDate(context, veterinarian),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension DateTimeFormatting on DateTime {
  String toFormattedDateString() {
    return DateFormat('dd/MM/yyyy').format(this);
  }
}