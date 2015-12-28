part of or_test_fw;

abstract class Peer {
  static Logger log = new Logger('Test.Peer');

  /**
   * Test for the presence of hangup events when a peer
   * changes registration status.
   */
  static Future eventPresence(Receptionist receptionist) async {
    String peerName = receptionist._phone.defaultAccount.username;

    log.info('Unregistering peer $peerName to assert state');

    Future unregisterEvent = receptionist.notificationSocket.eventStream
        .firstWhere((Event.Event e) =>
            e is Event.PeerState && e.peer.ID == peerName && !e.peer.registered)
        .timeout(new Duration(seconds: 10));

    await receptionist._phone.unregister();
    await unregisterEvent;

    log.info('Flushing event stack');
    receptionist.eventStack.clear();

    log.info('Registering peer $peerName');
    await receptionist._phone.register();
    log.info('Waiting for peer state event');

    Event.PeerState peerStateEvent =
        await receptionist.waitFor(eventType: Event.Key.peerState);
    log.info('Got event ${peerStateEvent.asMap}');
    expect(peerStateEvent.peer.registered, isTrue);
    expect(peerStateEvent.peer.ID, equals(peerName));

    log.info('Flushing event stack');
    receptionist.eventStack.clear();

    log.info('Unregistering peer $peerName to complete cycle');
    receptionist._phone.unregister();
    log.info('Waiting for peer state event');

    peerStateEvent = await receptionist.waitFor(eventType: Event.Key.peerState);

    log.info('Got event ${peerStateEvent.asMap}');
    expect(peerStateEvent.peer.registered, isFalse);
    expect(peerStateEvent.peer.ID, equals(peerName));

    log.info('Test done.');
  }

  static Future list(Service.CallFlowControl callFlowControl) => callFlowControl
      .peerList()
      .then((Iterable<Model.Peer> peers) => expect(peers.length, isPositive));
}
