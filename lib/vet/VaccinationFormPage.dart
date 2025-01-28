import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../app_route.dart';
import '../model/pet.dart';
import '../model/vaccination.dart';

class VaccinationFormPage extends StatefulWidget {
  final Pet pet;

  const VaccinationFormPage({super.key, required this.pet});

  @override
  _VaccinationFormPageState createState() => _VaccinationFormPageState();
}

class _VaccinationFormPageState extends State<VaccinationFormPage> {
  final _formKey = GlobalKey<FormState>();
  String vaccineName = '';
  DateTime? dateAdministered;
  TimeOfDay? timeAdministered;
  DateTime? nextDueDate;
  int _currentIndex = 2;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isSaving = false;

  Future<void> _saveVaccination() async {
    if (dateAdministered == null || dateAdministered!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The administration date cannot be in the future.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      Vaccination newVaccination = Vaccination(
        vaccineName: vaccineName,
        dateAdministered: dateAdministered!,
        nextDueDate: nextDueDate,
      );

      await _firestore
          .collection('pets')
          .doc(widget.pet.id)
          .collection('vaccinations')
          .add(newVaccination.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vaccination successfully registered!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  DateTime? _combineDateTime(DateTime date, TimeOfDay time) {
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          Get.toNamed(AppRoutes.vetPage);
          break;
        case 1:
          Get.toNamed(AppRoutes.vaccinationPage);
          break;
        case 2:
          Get.toNamed(AppRoutes.vetProfileUpdate);
          break;
        case 3:
          Get.toNamed(AppRoutes.dossierPage);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.vaccines, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Add a Vaccination',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Vaccination Details',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildStyledTextField(
                  label: 'Name of vaccine',
                  onChanged: (value) {
                    vaccineName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name of the vaccine.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDatePickerField(
                  context: context,
                  label: 'Date of administration',
                  date: dateAdministered,
                  onDatePicked: (pickedDate) {
                    setState(() {
                      dateAdministered = pickedDate;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTimePickerField(
                  context: context,
                  label: 'Administration time',
                  time: timeAdministered,
                  onTimePicked: (pickedTime) {
                    setState(() {
                      timeAdministered = pickedTime;
                      dateAdministered =
                          _combineDateTime(dateAdministered!, pickedTime!);
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDatePickerField(
                  context: context,
                  label: 'Next due date (optional)',
                  date: nextDueDate,
                  onDatePicked: (pickedDate) {
                    setState(() {
                      nextDueDate = pickedDate;
                    });
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: isSaving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveVaccination();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24), backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 12,
                      shadowColor: Colors.black54,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        onTap: _onBottomNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vaccines, size: 28),
            label: 'Vaccination',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital, size: 28),
            label: 'Track Vaccination',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder, size: 28),
            label: 'Dossiers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Dossier',
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required String label,
    required void Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required void Function(DateTime) onDatePicked,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: date != null ? '${date.toLocal()}'.split(' ')[0] : '',
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != date) {
          onDatePicked(picked);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date.';
        }
        return null;
      },
    );
  }

  Widget _buildTimePickerField({
    required BuildContext context,
    required String label,
    required TimeOfDay? time,
    required void Function(TimeOfDay) onTimePicked,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: time != null ? time.format(context) : '',
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (picked != null && picked != time) {
          onTimePicked(picked);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a time.';
        }
        return null;
      },
    );
  }
}
