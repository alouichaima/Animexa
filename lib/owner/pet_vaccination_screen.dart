import 'package:flutter/material.dart';
import 'package:animexa/services/notification_service.dart';
import '../model/pet.dart';
import '../model/vaccination.dart';
import 'package:animexa/services/VaccinationService.dart';

class PetVaccinationScreen extends StatefulWidget {
  final Pet pet;

  const PetVaccinationScreen({super.key, required this.pet});

  @override
  _PetVaccinationScreenState createState() => _PetVaccinationScreenState();
}

class _PetVaccinationScreenState extends State<PetVaccinationScreen> {
  final VaccinationService _vaccinationService = VaccinationService();
  final NotificationService _notificationService =
      NotificationService(); 
  List<Vaccination> _vaccinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVaccinations();
  }

  Future<void> _fetchVaccinations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      
      if (widget.pet.id != null) {
        _vaccinations =
            await _vaccinationService.getVaccinations(widget.pet.id!);
        
        _checkForUpcomingVaccines();
      } else {
        print('Pet ID is null, cannot fetch vaccinations.');
        
      }
    } catch (e) {
      
      print('Error fetching vaccinations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkForUpcomingVaccines() {
    for (var vaccination in _vaccinations) {
      if (vaccination.nextDueDate != null) {
        
        _notificationService.scheduleVaccineReminder(
            vaccination.nextDueDate!, vaccination.vaccineName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pet.nom} Vaccinations'),
        backgroundColor: Colors.blue[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vaccinations.isEmpty
              ? const Center(child: Text('No vaccinations found for this pet.'))
              : ListView.builder(
                  itemCount: _vaccinations.length,
                  itemBuilder: (context, index) {
                    Vaccination vaccination = _vaccinations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(vaccination.vaccineName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date Administered: ${vaccination.dateAdministered.toLocal().toShortDateString()}',
                            ),
                            if (vaccination.nextDueDate != null)
                              Text(
                                'Next Due: ${vaccination.nextDueDate!.toLocal().toShortDateString()}',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

extension DateTimeExtension on DateTime {
  String toShortDateString() {
    return "${this.day}/${this.month}/${this.year}";
  }
}
