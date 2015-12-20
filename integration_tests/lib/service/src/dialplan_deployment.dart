part of or_test_fw;

abstract class DialplanDeployment {
  static Future _sleep(int milliseconds) =>
      new Future.delayed(new Duration(milliseconds: milliseconds));

  static noHours(Customer customer, Service.RESTDialplanStore rdpStore,
      Storage.Reception rStore, esl.Connection eslClient) async {
    final Logger _log = new Logger('$libraryName.DialplanDeployment.noHours');
    List<esl.Event> events = [];
    eslClient.eventStream.listen(events.add);

    //TODO: event subscriptions.
    Model.ReceptionDialplan rdp = new Model.ReceptionDialplan()
      ..open = []
      ..extension = 'test-${Randomizer.randomPhoneNumber()}'
          '-${new DateTime.now().millisecondsSinceEpoch}'
      ..defaultActions =
          [new Model.Playback('sorry-dude-were-closed'),
           new Model.Playback('sorry-dude-were-really-closed')

          ]
      ..active = true;

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);
    Model.Reception r = await rStore.create(Randomizer.randomReception()
      ..enabled = true
      ..dialplan = createdDialplan.extension);
    await rdpStore.deployDialplan(rdp.extension, r.ID);
    await rdpStore.reloadConfig();

    _log.info('Subscribing for events.');
    await eslClient.event(['CHANNEL_EXECUTE'], format: 'json');

    await customer.dial(rdp.extension);
    await _sleep(2000);
    await customer.hangupAll();

    /// Check event queue.
    final int playback1 = events.indexOf(events.firstWhere((event) =>
        event.field('Application-Data') != null &&
            event
                .field('Application-Data')
                .contains('sorry-dude-were-closed')));

    final int playback2 = events.indexOf(events.firstWhere((event) =>
        event.field('Application-Data') != null &&
            event
                .field('Application-Data')
                .contains('sorry-dude-were-really-closed')));

    expect (playback1, lessThan(playback2));

    /// Cleanup.
    _log.info('Test successful. Cleaning up.');

    await rStore.remove(r.ID);
    await rdpStore.remove(createdDialplan.extension);
  }
}
