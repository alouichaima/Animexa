import 'package:flutter/material.dart';
import 'package:animexa/services/notification_service.dart';
import '../model/pet.dart';
import '../model/vaccination.dart';
import 'package:animexa/services/VaccinationService.dart';

class Track_vaccination extends StatefulWidget {
  final Pet pet;

  const Track_vaccination({super.key, required this.pet});

  @override
  _Track_vaccinationState createState() => _Track_vaccinationState();
}

class _Track_vaccinationState extends State<Track_vaccination> {
  final VaccinationService _vaccinationService = VaccinationService();
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
        _vaccinations = await _vaccinationService.getVaccinations(widget.pet.id!);
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pet.nom} Vaccinations'),
        backgroundColor: Colors.blue[800],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vaccinations.isEmpty
          ? const Center(child: Text('No vaccinations found for this pet.'))
          : ListView.builder(
        itemCount: _vaccinations.length,
        itemBuilder: (context, index) {
          Vaccination vaccination = _vaccinations[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Card(
              elevation: 4, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), 
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  vaccination.vaccineName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Administered: ${vaccination.dateAdministered.toLocal().toShortDateString()}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (vaccination.nextDueDate != null)
                      Text(
                        'Next Due: ${vaccination.nextDueDate!.toLocal().toShortDateString()}',
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    if (vaccination.nextDueDate != null && vaccination.nextDueDate!.isBefore(DateTime.now().add(Duration(days: 2))))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Reminder: Vaccination due soon!',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
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
