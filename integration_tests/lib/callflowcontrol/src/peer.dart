part of or_test_fw;

abstract class Peer {

  static Logger log = new Logger ('Test.Peer');

  /**
   * Test for the presence of hangup events when a peer
   * changes registration status.
   */
  static Future eventPresence() {
    Receptionist receptionist = ReceptionistPool.instance.aquire();
    String peerName = receptionist._phone.defaultAccount.username;
    return
      Future.wait([receptionist.initialize()])
      .then((_) => log.info ('Unregistering peer $peerName to assert state'))
      .then((_) => receptionist._phone.unregister())
      .then((_) => log.info ('Flushing event stack'))
      .then((_) => receptionist.eventStack.clear())
      .then((_) => log.info ('Registering peer $peerName'))
      .then((_) => receptionist._phone.register())
      .then((_) => log.info ('Waiting for peer state event'))
      .then((_) =>
          receptionist.waitFor(eventType: Model.EventJSONKey.peerState)
          .then((Model.PeerState peerStateEvent) {
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
          receptionist.waitFor(eventType: Model.EventJSONKey.peerState)
          .then((Model.PeerState peerStateEvent) {
            log.info ('Got event ${peerStateEvent.asMap}');
            expect (peerStateEvent.peer.registered, isFalse);
            expect (peerStateEvent.peer.ID, equals(peerName));
          }))
      .then((_) => log.info ('Test done. Cleaning up'))
      .whenComplete(() {
        ReceptionistPool.instance.release(receptionist);
        return Future.wait([receptionist.teardown()])
            .catchError(log.severe);
      });
  }

  static Future list () {

  }
//
//  def test_event_and_list_presence(self):
//
//          self.log.info ("Unregistering agent to assert that we get a registration event.")
//          receptionist.sip_phone.Unregister()
//
//
//          self.log.info ("Flushing event stack.")
//          receptionist.event_stack.flush() # Purge any registration events.
//
//          self.log.info ("Registering receptionst sip agent.")
//          receptionist.sip_phone.Register()
//          self.log.info ("Expecting peer_state event.")
//          receptionist.event_stack.WaitFor(event_type="peer_state")
//
//          self.log.info ("Event received, looking up receptionist in peerlist.")
//          peer = receptionist.call_control.peerList().locatePeer(receptionist.username)
//          if not peer ['registered']:
//              self.fail (receptionist.username + " expected to be in peer list at this point")
//
//          self.log.info ("Flushing event stack.")
//          receptionist.event_stack.flush() # Purge any registration events.
//
//          self.log.info ("Unregistering agent again to complete cycle.")
//          receptionist.sip_phone.Unregister()
//
//          self.log.info ("Expecting peer_state event.")
//          receptionist.event_stack.WaitFor(event_type="peer_state")
//
//          self.log.info ("Event received, looking up receptionist in peerlist.")
//          peer = receptionist.call_control.peerList().locatePeer(receptionist.username)
//          if peer ['registered']:
//              self.fail("Peer is still registered: " + str (peer))
//
//          self.log.info ("Peer is no longer registered, run complete.")
//          receptionist.release()
//
//      except:
//          receptionist.release()
//          raise
}