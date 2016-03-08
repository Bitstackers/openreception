part of openreception_tests.support;

class TestEnvironment {
  Logger _log = new Logger('TestEnvironment');
  model.User _user = new model.User.empty()
    ..id = 0
    ..name = 'System User'
    ..address = 'openreception@localhost';

  /**
   *
   */
  filestore.User _userStore;
  filestore.User get userStore {
    if (_userStore == null) {
      final String path = '${runpath.path}/user';
      _log.info('Creating user store from $path');
      _userStore = new filestore.User(path: path);
    }

    return _userStore;
  }

  /**
   *
   */
  filestore.Ivr _ivrStore;
  filestore.Ivr get ivrStore {
    if (_ivrStore == null) {
      final String path = '${runpath.path}/ivr';
      _log.info('Creating ivr store from $path');
      _ivrStore = new filestore.Ivr(path: path);
    }

    return _ivrStore;
  }

  /**
   *
   */
  filestore.ReceptionDialplan _dpStore;
  filestore.ReceptionDialplan get dialplanStore {
    if (_dpStore == null) {
      final String path = '${runpath.path}/dialplan';
      _log.info('Creating dialplan store from $path');

      _dpStore = new filestore.ReceptionDialplan(path: path);
    }

    return _dpStore;
  }

  /**
   *
   */
  filestore.Calendar _calendarStore;
  filestore.Calendar get calendarStore {
    if (_calendarStore == null) {
      final String path = '${runpath.path}/calendar';
      _log.info('Creating calendar store from $path');

      _calendarStore = new filestore.Calendar(path: path);
    }

    return _calendarStore;
  }

  /**
   *
   */
  filestore.Contact _contactStore;
  filestore.Contact get contactStore {
    if (_contactStore == null) {
      final String path = '${runpath.path}/contact';
      _log.info('Creating calendar store from $path');

      _contactStore = new filestore.Contact(receptionStore, path: path);
    }

    return _contactStore;
  }

  /**
   *
   */
  filestore.Message _messageStore;
  filestore.Message get messageStore {
    if (_messageStore == null) {
      final String path = '${runpath.path}/message';
      _log.info('Creating message store from $path');

      _messageStore = new filestore.Message(path: path);
    }

    return _messageStore;
  }

  /**
   *
   */
  filestore.MessageQueue _messageQueue;
  filestore.MessageQueue get messageQueue {
    if (_messageQueue == null) {
      final String path = '${runpath.path}/message_queue';
      _log.info('Creating message queue store from $path');

      _messageQueue = new filestore.MessageQueue(messageStore, path: path);
    }

    return _messageQueue;
  }

  /**
   *
   */
  filestore.Reception _receptionStore;
  filestore.Reception get receptionStore {
    if (_receptionStore == null) {
      final String path = '${runpath.path}/reception';
      _log.info('Creating reception store from $path');

      _receptionStore = new filestore.Reception(path: path);
    }

    return _receptionStore;
  }

  /**
   *
   */
  filestore.Organization _organizationStore;
  filestore.Organization get organizationStore {
    if (_organizationStore == null) {
      final String path = '${runpath.path}/organization';
      _log.info('Creating organization store from $path');

      _organizationStore =
          new filestore.Organization(contactStore, receptionStore, path: path);
    }

    return _organizationStore;
  }

  final Directory runpath;

  TestEnvironment() : runpath = new Directory('/tmp').createTempSync() {
    _log.info('New test environment created in directory $runpath');
  }

  /**
   *
   */
  void clear() {
    _log.info('Clearing test environment created in directory $runpath');
    runpath.deleteSync(recursive: true);
    _userStore = null;
    _contactStore = null;
  }

  /**
   *
   */
  Future<ServiceAgent> createsServiceAgent() async {
    await userStore.ready;
    model.User sa = Randomizer.randomUser()
      ..groups = [model.UserGroups.serviceAgent].toSet();

    sa.id = (await _userStore.create(sa, _user)).id;

    return new ServiceAgent(runpath, sa, this);
  }

  /**
   *
   */
  Future removesServiceAgent(model.User serviceAgent) async {
    await _userStore.ready;
    await _userStore.remove(serviceAgent.id, _user);
  }
}
