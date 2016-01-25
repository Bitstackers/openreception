part of or_test_fw;

abstract class DialplanDeployment {
  /**
   * TODO: Verify reception-id.
   */
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
      ..defaultActions = [
        new Model.Playback('sorry-dude-were-closed'),
        new Model.Playback('sorry-dude-were-really-closed')
      ]
      ..active = true;

    Model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);
    _log.info('Created dialplan: ${createdDialplan.toJson()}');
    Model.Reception r = await rStore.create(Randomizer.randomReception()
      ..enabled = true
      ..dialplan = createdDialplan.extension);
    await rdpStore.deployDialplan(rdp.extension, r.ID);
    await rdpStore.reloadConfig();

    _log.info('Subscribing for events.');

    await eslClient.event(['CHANNEL_EXECUTE'], format: 'json');

    await customer.dial(rdp.extension);

    _log.info('Awaiting $customer\'s phone to hang up');
    await customer.waitForHangup().timeout(new Duration(seconds: 10));

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

    expect(playback1, lessThan(playback2));

    /// Cleanup.
    _log.info('Test successful. Cleaning up.');

    await rStore.remove(r.ID);
    await rdpStore.remove(createdDialplan.extension);
  }

  /**
   *
   */
  static openHoursOpen(Customer customer, Service.RESTDialplanStore rdpStore,
      Storage.Reception rStore, esl.Connection eslClient) async {
    final Logger _log =
        new Logger('$libraryName.DialplanDeployment.openHoursOpen');
    List<esl.Event> events = [];
    eslClient.eventStream.listen(events.add);

    final DateTime now = new DateTime.now();
    Model.OpeningHour justNow = new Model.OpeningHour.empty()
      ..fromDay = toWeekDay(now.weekday)
      ..toDay = toWeekDay(now.weekday)
      ..fromHour = now.hour
      ..toHour = now.hour + 1
      ..fromMinute = now.minute
      ..toMinute = now.minute;

    //TODO: event subscriptions.
    Model.ReceptionDialplan rdp = new Model.ReceptionDialplan()
      ..open = [
        new Model.HourAction()
          ..hours = [justNow]
          ..actions = [
            new Model.Playback('sorry-dude-were-open'),
            new Model.Playback('sorry-dude-were-really-open')
          ]
      ]
      ..extension = 'test-${Randomizer.randomPhoneNumber()}'
          '-${new DateTime.now().millisecondsSinceEpoch}'
      ..defaultActions = [new Model.Playback('sorry-dude-were-closed')]
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

    _log.info('Awaiting $customer\'s phone to hang up');
    await customer.waitForHangup().timeout(new Duration(seconds: 10));

    /// Check event queue.
    final int playback1 = events.indexOf(events.firstWhere((event) =>
        event.field('Application-Data') != null &&
            event.field('Application-Data').contains('sorry-dude-were-open')));

    final int playback2 = events.indexOf(events.firstWhere((event) =>
        event.field('Application-Data') != null &&
            event
                .field('Application-Data')
                .contains('sorry-dude-were-really-open')));

    expect(playback1, lessThan(playback2));

    /// Cleanup.
    _log.info('Test successful. Cleaning up.');

    await rStore.remove(r.ID);
    await rdpStore.remove(createdDialplan.extension);
  }

  /**
   *
   */
  static receptionTransfer(
      Customer customer,
      Service.RESTDialplanStore rdpStore,
      Storage.Reception rStore,
      esl.Connection eslClient) async {
    final Logger _log = new Logger('$libraryName.DialplanDeployment.noHours');
    List<esl.Event> events = [];
    eslClient.eventStream.listen(events.add);

    final DateTime now = new DateTime.now();
    Model.OpeningHour justNow = new Model.OpeningHour.empty()
      ..fromDay = toWeekDay(now.weekday)
      ..toDay = toWeekDay(now.weekday)
      ..fromHour = now.hour
      ..toHour = now.hour + 1
      ..fromMinute = now.minute
      ..toMinute = now.minute;

    final String firstDialplanGreeting = 'I-am-the-first-greeting';
    final String firstDialplanExtension =
        'test-${Randomizer.randomPhoneNumber()}'
        '-${new DateTime.now().millisecondsSinceEpoch}-1';

    final String secondDialplanGreeting = 'I-am-the-second-greeting';
    final String secondDialplanExtension =
        'test-${Randomizer.randomPhoneNumber()}'
        '-${new DateTime.now().millisecondsSinceEpoch}-2';

    final Model.ReceptionDialplan firstDialplan =
        await rdpStore.create(new Model.ReceptionDialplan()
          ..extension = firstDialplanExtension
          ..open = [
            new Model.HourAction()
              ..hours = [justNow]
              ..actions = [
                new Model.Playback(firstDialplanGreeting),
                new Model.ReceptionTransfer(secondDialplanExtension)
              ],
          ]
          ..active = true);
    _log.info('Created dialplan: ${firstDialplan.toJson()}');

    final Model.ReceptionDialplan secondDialplan =
        await rdpStore.create(new Model.ReceptionDialplan()
          ..extension = secondDialplanExtension
          ..open = [
            new Model.HourAction()
              ..hours = [justNow]
              ..actions = [new Model.Playback(secondDialplanGreeting)],
          ]
          ..active = true);

    Model.Reception r = await rStore.create(Randomizer.randomReception()
      ..enabled = true
      ..dialplan = firstDialplan.extension);
    await rdpStore.deployDialplan(firstDialplan.extension, r.ID);
    await rdpStore.deployDialplan(secondDialplan.extension, r.ID);
    await rdpStore.reloadConfig();

    _log.info('Subscribing for events.');

    await eslClient.event(['CHANNEL_EXECUTE'], format: 'json');

    await customer.dial(firstDialplan.extension);

    _log.info('Awaiting $customer\'s phone to hang up');
    await customer.waitForHangup().timeout(new Duration(seconds: 10));

    /// Check event queue.
    final int playback1 = events.indexOf(events.firstWhere((event) =>
        event.field('Application-Data') != null &&
            event.field('Application-Data').contains(firstDialplanGreeting)));

    final int playback2 = events.indexOf(events.firstWhere((event) =>
        event.field('Application-Data') != null &&
            event.field('Application-Data').contains(secondDialplanGreeting)));

    expect(playback1, lessThan(playback2));

    /// Cleanup.
    _log.info('Test successful. Cleaning up.');

    await rStore.remove(r.ID);
    await rdpStore.remove(firstDialplan.extension);
    await rdpStore.remove(secondDialplan.extension);
  }
}
