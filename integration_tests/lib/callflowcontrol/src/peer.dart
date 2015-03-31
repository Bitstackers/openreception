part of or_test_fw;

abstract class Peer {

  static Logger log = new Logger ('Test.Peer');

  /**
   * Test for the presence of hangup events when a peer
   * changes registration status.
   */
  static Future eventPresence(Receptionist receptionist) {
    String peerName = receptionist._phone.defaultAccount.username;

    return
      Future.wait([])
      .then((_) => log.info ('Unregistering peer $peerName to assert state'))
      .then((_) => receptionist._phone.unregister())
      .then((_) => log.info ('Flushing event stack'))
      .then((_) => receptionist.eventStack.clear())
      .then((_) => log.info ('Registering peer $peerName'))
      .then((_) => receptionist._phone.register())
      .then((_) => log.info ('Waiting for peer state event'))
      .then((_) =>
          receptionist.waitFor(eventType: Event.Key.peerState)
          .then((Event.PeerState peerStateEvent) {
            log.info ('Got event ${peerStateEvent.asMap}');
            expect (peerStateEvent.peer.registered, isTrue);
            expect (peerStateEvent.peer.ID, equals(peerName));
          }))
      .then((_) => log.info ('Flushing event stack'))
      .then((_) => receptionist.eventStack.clear())
      .then((_) => log.info ('Unregistering peer $peerName to complete cycle'))
      .then((_) => receptionist._phone.unregister())
      .then((_) => log.info ('Waiting for peer state event'))
      .then((_) =>
          receptionist.waitFor(eventType: Event.Key.peerState)
          .then((Event.PeerState peerStateEvent) {
            log.info ('Got event ${peerStateEvent.asMap}');
            expect (peerStateEvent.peer.registered, isFalse);
            expect (peerStateEvent.peer.ID, equals(peerName));
          }))
      .then((_) => log.info ('Test done.'));
  }

  static Future list (Service.CallFlowControl callFlowControl) =>
    callFlowControl.peerList().then((Iterable<Model.Peer> peers) =>
      expect (peers.length, isPositive));
}