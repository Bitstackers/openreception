part of or_test_fw;

abstract class NotificationService {

  static Future eventBroadcast(Iterable<Receptionist> receptionists) {
    receptionists.forEach((Receptionist receptionist) {
      receptionist.eventStack.clear();
    });

    return receptionists.first.paused().then((_) =>
      Future.forEach(receptionists, (Receptionist receptionist) =>
        receptionist.waitFor(eventType : Event.Key.userState)));
  }

}