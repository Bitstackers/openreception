part of openreception_tests.support;

int _currentInternalPeerName = 1100;
String get _nextInternalPeerName {
  String peername = _currentInternalPeerName.toString();
  _currentInternalPeerName++;
  return peername;
}

int _currentExternalPeerName = 1200;
String get _nextExternalPeerName {
  String peername = _currentExternalPeerName.toString();
  _currentExternalPeerName++;
  return peername;
}

process.FreeSwitch _freeswitch;

class TestEnvironment {
  Logger _log = new Logger('TestEnvironment');
  model.User _user = new model.User.empty()
    ..id = 0
    ..name = 'System User'
    ..address = 'openreception@localhost';

  final PhonePool phonePool = new PhonePool.empty();
  final Directory runpath;
  final Directory fsDir;

  List<Receptionist> allocatedReceptionists = [];
  List<Customer> allocatedCustomers = [];

  /**
   *
   */
  Future<process.FreeSwitch> get freeswitchProcess async {
    if (_freeswitch == null) {
      _freeswitch = new process.FreeSwitch(
          '/usr/bin/freeswitch',
          fsDir.path,
          new File(
              '/home/krc/Projects/openreception-integration-tests/conf.tar.gz'));
    }
    await _freeswitch.whenReady;
    return _freeswitch;
  }

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

  /**
   *
   */
  TestEnvironment({String path: ''})
      : fsDir = path.isEmpty
            ? new Directory('/tmp').createTempSync('freeswitch-')
            : new Directory(path + '/freeswitch-conf')..createSync(),
        runpath = path.isEmpty
            ? new Directory('/tmp').createTempSync('filestore')
            : new Directory(path + '/filestore')..createSync() {
    _log.info('New test environment created in directory $runpath');
  }

  /**
   *
   */
  Future clear() async {
    await _clearProcesses();

    if (!runpath.existsSync()) {
      _log.info('Clearing test environment created in directory $runpath');
      runpath.deleteSync(recursive: true);
    }

    _userStore = null;
    _dpStore = null;
    _calendarStore = null;
    _userStore = null;
    _contactStore = null;
    _messageStore = null;
    _messageQueue = null;
    _receptionStore = null;
    _organizationStore = null;

    if (_freeswitch != null) {
      await _freeswitch.cleanConfig();
    }
  }

/**
 *
 */
  Future _clearProcesses() async {
    await Future.wait(allocatedReceptionists.map((r) => r.finalize()));
    allocatedReceptionists = [];
    await Future.wait(allocatedCustomers.map((r) => r.finalize()));
    allocatedCustomers = [];
  }

  /**
   *
   */
  Future finalize() async {
    await clear();
    if (_freeswitch != null) {
      await _freeswitch.terminate();
    }
    _log.info('Deleting directory ${fsDir.absolute.path}');
    await fsDir.deleteSync(recursive: true);
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
