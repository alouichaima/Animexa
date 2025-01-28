import 'package:animexa/model/appointment.dart';
import 'package:animexa/model/pet.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';

class NotificationService {
 
  void scheduleVaccineReminder(DateTime nextDueDate, String vaccineName) {
    
    DateTime twoDaysBefore = nextDueDate.subtract(const Duration(days: 1));

    if (twoDaysBefore.isBefore(DateTime.now())) {
      return; 
    }

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, 
        channelKey: 'vaccine_notifications', 
        title: 'Time to Vaccinate $vaccineName!',
        body: 'Reminder: The $vaccineName is due in 4 days for your pet.',
        notificationLayout: NotificationLayout.Default,
        actionType: ActionType.Default,
      ),
    );
  }

  void scheduleAppointmentReminder(
      DateTime appointmentDate, String veterinarianName) {
    
    DateTime oneDayBefore = appointmentDate.subtract(const Duration(days: 1));

    
    DateTime notificationTime =
        DateTime(oneDayBefore.year, oneDayBefore.month, oneDayBefore.day);

    
    if (notificationTime.isBefore(DateTime.now())) {
      notificationTime = notificationTime.add(Duration(days: 1));
    }

    
    print('Appointment reminder scheduled for: $notificationTime');

    int notificationId =
        appointmentDate.hashCode; 

  
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'appointment_notifications',
        title: 'Appointment Reminders',
        body:
            'You have an appointment on ${DateFormat('d MMMM yyyy').format(appointmentDate)} with Dr. $veterinarianName.',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
