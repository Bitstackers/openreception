part of openreception_tests.service;

abstract class DialplanDeployment {
  /**
   *
   */
  static noHours(Customer customer, service.RESTDialplanStore rdpStore,
      storage.Reception rStore, esl.Connection eslClient) async {
    final Logger _log = new Logger('$_namespace.DialplanDeployment.noHours');
    List<esl.Event> events = [];
    eslClient.eventStream.listen(events.add);

    model.ReceptionDialplan rdp = new model.ReceptionDialplan()
      ..open = []
      ..extension = 'test-${Randomizer.randomPhoneNumber()}'
          '-${new DateTime.now().millisecondsSinceEpoch}'
      ..defaultActions = [
        new model.Playback('sorry-dude-were-closed'),
        new model.Playback('sorry-dude-were-really-closed')
      ]
      ..active = true;

    model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);
    _log.info('Created dialplan: ${createdDialplan.toJson()}');
    model.ReceptionReference r = await rStore.create(
        Randomizer.randomReception()
          ..enabled = true
          ..dialplan = createdDialplan.extension,
        new model.User.empty());
    await rdpStore.deployDialplan(rdp.extension, r.id);
    await rdpStore.reloadConfig();

    _log.info('Subscribing for events.');

    await eslClient.event(['CHANNEL_EXECUTE'], format: 'json');

    await customer.dial(rdp.extension);

    _log.info('Awaiting $customer\'s phone to hang up');
    await customer.waitForHangup().timeout(new Duration(seconds: 10));
    await new Future.delayed(new Duration(milliseconds: 100));

    /// Check event queue.
    final int playback1 = events.indexOf(events.firstWhere((esl.Event event) =>
        event.fields['Application-Data'] != null &&
        event.fields['Application-Data'].contains('sorry-dude-were-closed')));

    final int playback2 = events.indexOf(events.firstWhere((event) =>
        event.fields['Application-Data'] != null &&
        event.fields['Application-Data']
            .contains('sorry-dude-were-really-closed')));

    expect(playback1, lessThan(playback2));

    /// Cleanup.
    _log.info('Test successful. Cleaning up.');

    await rStore.remove(r.id, new model.User.empty());
    await rdpStore.remove(createdDialplan.extension);
  }

  /**
   *
   */
  static openHoursOpen(Customer customer, service.RESTDialplanStore rdpStore,
      storage.Reception rStore, esl.Connection eslClient) async {
    final Logger _log =
        new Logger('$_namespace.DialplanDeployment.openHoursOpen');
    List<esl.Event> events = [];
    eslClient.eventStream.listen(events.add);

    final DateTime now = new DateTime.now();
    model.OpeningHour justNow = new model.OpeningHour.empty()
      ..fromDay = toWeekDay(now.weekday)
      ..toDay = toWeekDay(now.weekday)
      ..fromHour = now.hour
      ..toHour = now.hour + 1
      ..fromMinute = now.minute
      ..toMinute = now.minute;

    model.ReceptionDialplan rdp = new model.ReceptionDialplan()
      ..open = [
        new model.HourAction()
          ..hours = [justNow]
          ..actions = [
            new model.Playback('sorry-dude-were-open'),
            new model.Playback('sorry-dude-were-really-open')
          ]
      ]
      ..extension = 'test-${Randomizer.randomPhoneNumber()}'
          '-${new DateTime.now().millisecondsSinceEpoch}'
      ..defaultActions = [new model.Playback('sorry-dude-were-closed')]
      ..active = true;

    model.ReceptionDialplan createdDialplan = await rdpStore.create(rdp);
    model.ReceptionReference r = await rStore.create(
        Randomizer.randomReception()
          ..enabled = true
          ..dialplan = createdDialplan.extension,
        new model.User.empty());
    await rdpStore.deployDialplan(rdp.extension, r.id);
    await rdpStore.reloadConfig();

    _log.info('Subscribing for events.');
    await eslClient.event(['CHANNEL_EXECUTE'], format: 'json');

    await customer.dial(rdp.extension);

    _log.info('Awaiting $customer\'s phone to hang up');
    await customer.waitForHangup().timeout(new Duration(seconds: 10));
    await new Future.delayed(new Duration(milliseconds: 100));

    /// Check event queue.
    final int playback1 = events.indexOf(events.firstWhere((esl.Event event) =>
        event.fields['Application-Data'] != null &&
        event.fields['Application-Data'].contains('sorry-dude-were-open')));

    final int playback2 = events.indexOf(events.firstWhere((esl.Event event) =>
        event.fields['Application-Data'] != null &&
        event.fields['Application-Data']
            .contains('sorry-dude-were-really-open')));

    expect(playback1, lessThan(playback2));

    /// Cleanup.
    _log.info('Test successful. Cleaning up.');

    await rStore.remove(r.id, new model.User.empty());
    await rdpStore.remove(createdDialplan.extension);
  }

  /**
   *
   */
  static receptionTransfer(
      Customer customer,
      service.RESTDialplanStore rdpStore,
      storage.Reception rStore,
      esl.Connection eslClient) async {
    final Logger _log = new Logger('$_namespace.DialplanDeployment.noHours');
    List<esl.Event> events = [];
    eslClient.eventStream.listen(events.add);

    final DateTime now = new DateTime.now();
    model.OpeningHour justNow = new model.OpeningHour.empty()
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

    final model.ReceptionDialplan firstDialplan =
        await rdpStore.create(new model.ReceptionDialplan()
          ..extension = firstDialplanExtension
          ..open = [
            new model.HourAction()
              ..hours = [justNow]
              ..actions = [
                new model.Playback(firstDialplanGreeting),
                new model.ReceptionTransfer(secondDialplanExtension)
              ],
          ]
          ..active = true);
    _log.info('Created dialplan: ${firstDialplan.toJson()}');

    final model.ReceptionDialplan secondDialplan =
        await rdpStore.create(new model.ReceptionDialplan()
          ..extension = secondDialplanExtension
          ..open = [
            new model.HourAction()
              ..hours = [justNow]
              ..actions = [new model.Playback(secondDialplanGreeting)],
          ]
          ..active = true);

    model.ReceptionReference r = await rStore.create(
        Randomizer.randomReception()
          ..enabled = true
          ..dialplan = firstDialplan.extension,
        new model.User.empty());
    await rdpStore.deployDialplan(firstDialplan.extension, r.id);
    await rdpStore.deployDialplan(secondDialplan.extension, r.id);
    await rdpStore.reloadConfig();

    _log.info('Subscribing for events.');

    await eslClient.event(['CHANNEL_EXECUTE'], format: 'json');

    await customer.dial(firstDialplan.extension);

    _log.info('Awaiting $customer\'s phone to hang up');
    await customer.waitForHangup().timeout(new Duration(seconds: 10));
    await new Future.delayed(new Duration(milliseconds: 100));

    /// Check event queue.
    final int playback1 = events.indexOf(events.firstWhere((event) =>
        event.fields['Application-Data'] != null &&
        event.fields['Application-Data'].contains(firstDialplanGreeting)));

    final int playback2 = events.indexOf(events.firstWhere((event) =>
        event.fields['Application-Data'] != null &&
        event.fields['Application-Data'].contains(secondDialplanGreeting)));

    expect(playback1, lessThan(playback2));

    /// Cleanup.
    _log.info('Test successful. Cleaning up.');

    await rStore.remove(r.id, new model.User.empty());
    await rdpStore.remove(firstDialplan.extension);
    await rdpStore.remove(secondDialplan.extension);
  }
}
