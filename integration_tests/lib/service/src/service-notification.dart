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

  static Future connectionStateList(Iterable<Receptionist> receptionists, 
                                    Service.NotificationService notificationService) {
    receptionists.forEach((Receptionist receptionist) {
      receptionist.eventStack.clear();
    });
    
    bool receptionistHasConnection(Receptionist receptionist, Iterable<Model.ClientConnection> connections) =>
      connections.where((Model.ClientConnection connection) => 
          connection.userID ==receptionist.user.ID && connection.connectionCount > 0).length > 0; 
    
    
    return notificationService.clientConnections().then((Iterable<Model.ClientConnection> connections) {
      expect(receptionists.every((Receptionist r) => receptionistHasConnection(r, connections)), isTrue);
      expect(connections.every((Model.ClientConnection conn) => conn.userID > 0), isTrue);
    });
  }
  
  static Future connectionState(Iterable<Receptionist> receptionists, 
                                    Service.NotificationService notificationService) {
    receptionists.forEach((Receptionist receptionist) {
      receptionist.eventStack.clear();
    });
    
    return Future.forEach(receptionists, (Receptionist r) {
      return notificationService.clientConnection(r.user.ID).then((Model.ClientConnection conn) {
        expect(conn.connectionCount, greaterThan(0));
        expect(conn.userID, equals(r.user.ID));
      });
    });

  }
  
  
//  static Future clientConnectionState(Iterable<Receptionist> receptionists) {
//    receptionists.forEach((Receptionist receptionist) {
//      receptionist.eventStack.clear();
//    });
//    
//    return receptionists.first.paused().then((_) =>
//      Future.forEach(receptionists, (Receptionist receptionist) =>
//        receptionist.waitFor(eventType : Event.Key.userState)));
//  }

//  static Future eventSend(Iterable<Receptionist> receptionists,
//                              Service.NotificationService notificationService) {
//    // This test make no sense with only two participants
//    expect(receptionists.length, greaterThan(2));
//
//    receptionists.forEach((Receptionist receptionist) {
//      receptionist.eventStack.clear();
//    });
//
//    Iterable<int> recipientUids = receptionists.map((r) => r.user.ID);
//
//    return notificationService.send(recipientUids, new Event.UserState())
//
//    return receptionists.first.paused().then((_) =>
//      Future.forEach(receptionists, (Receptionist receptionist) =>
//        receptionist.waitFor(eventType : Event.Key.userState)));
//  }
}