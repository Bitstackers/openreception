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

class TestEnvironmentConfig {
  String externalIp;

  Future detectEnvironment() async {
    final nics = await NetworkInterface.list();
    externalIp = nics.first.addresses.first.address;
  }

  String toString() => '''
Test environment:
  External IP: $externalIp''';
}

TestEnvironmentConfig _envConfig = new TestEnvironmentConfig();

class CircularCounter {
  final int _start;
  int _count;
  final int _max;

  int get nextInt {
    final int count = _count;

    if (_count == _max) {
      _count = _start;
    } else {
      _count = _count + 1;
    }

    return count;
  }

  CircularCounter(this._start, this._max) {
    _count = _start;
  }
}

CircularCounter _networkPortCounter = new CircularCounter(4000, 6000);

class TestEnvironment {
  Logger _log = new Logger('TestEnvironment');
  model.User _user = new model.User.empty()
    ..id = 0
    ..name = 'System User'
    ..address = 'openreception@localhost';

  TestEnvironmentConfig get envConfig => _envConfig;
  final PhonePool phonePool = new PhonePool.empty();
  final Directory runpath;

  /// Processes
  process.AuthServer _authProcess;
  process.NotificationServer _notificationProcess;
  process.DialplanServer _dialplanProcess;
  process.CallFlowControl _callflowProcess;

  service.Client _httpClient;

  List<service.WebSocketClient> _allocatedWebSockets = [];

  /**
   *
   */
  service.Client get httpClient =>
      _httpClient != null ? _httpClient : new service.Client();

  int get nextNetworkport => _networkPortCounter.nextInt;

  List<Receptionist> allocatedReceptionists = [];
  List<Customer> allocatedCustomers = [];

  /**
   *
   */
  Future<process.FreeSwitch> requestFreeswitchProcess() async {
    if (_freeswitch == null) {
      _freeswitch = new process.FreeSwitch(
          '/usr/bin/freeswitch',
          new Directory('/tmp').createTempSync('freeswitch-').path,
          new File('conf.tar.gz'));
    }
    await _freeswitch.whenReady;
    return _freeswitch;
  }

  /**
   *
   */
  service.WebSocketClient requestWebsocket() {
    final ws = new service.WebSocketClient();
    _allocatedWebSockets.add(ws);

    return ws;
  }

  /**
   *
   */
  Future<process.AuthServer> requestAuthserverProcess() async {
    _log.shout((await userTokens).join(', '));
    if (_authProcess == null) {
      _authProcess = new process.AuthServer(
          Config.serverStackPath, runpath.path,
          intialTokens: [new AuthToken(_user)]..addAll(await userTokens),
          bindAddress: envConfig.externalIp,
          servicePort: nextNetworkport);
    }

    await _authProcess.whenReady;

    return _authProcess;
  }

  /**
   *
   */
  Future<process.DialplanServer> requestDialplanProcess() async {
    if (_dialplanProcess == null) {
      _dialplanProcess = new process.DialplanServer(Config.serverStackPath,
          runpath.path, (await requestFreeswitchProcess()).confPath,
          authUri: (await requestAuthserverProcess()).uri,
          bindAddress: envConfig.externalIp,
          servicePort: nextNetworkport);
    }

    await _dialplanProcess.whenReady;

    return _dialplanProcess;
  }

  /**
   *
   */
  Future<process.CallFlowControl> requestCallFlowProcess() async {
    if (_callflowProcess == null) {
      _callflowProcess = new process.CallFlowControl(
          Config.serverStackPath, runpath.path,
          bindAddress: envConfig.externalIp,
          servicePort: nextNetworkport,
          notificationUri: (await requestNotificationserverProcess()).uri,
          authUri: (await requestAuthserverProcess()).uri);
    }

    await _callflowProcess.whenReady;

    return _callflowProcess;
  }

  /**
   *
   */
  Future<process.NotificationServer> requestNotificationserverProcess() async {
    if (_notificationProcess == null) {
      _notificationProcess = new process.NotificationServer(
          Config.serverStackPath, runpath.path,
          bindAddress: envConfig.externalIp,
          servicePort: nextNetworkport,
          authUri: (await requestAuthserverProcess()).uri);
    }

    await _notificationProcess.whenReady;

    return _notificationProcess;
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
      : runpath = path.isEmpty
            ? new Directory('/tmp').createTempSync('filestore')
            : new Directory(path + '/filestore')..createSync() {
    _log.info('New test environment created in directory $runpath');
  }

  /**
   *
   */
  Future _clearWebsockets() async {
    await Future.forEach(_allocatedWebSockets,
        (service.WebSocketClient ws) async {
      try {
        await ws.close();
      } catch (e, s) {
        _log.warning('Failed to close websocket', e, s);
      }
    });
  }

  /**
   *
   */
  Future clear() async {
    await _clearProcesses();
    await _clearWebsockets();

    if (_httpClient != null) {
      _httpClient.client.close(force: true);
    }

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

    if (_callflowProcess != null) {
      _log.info('Shutting down callflow process');
      await _callflowProcess.terminate();
    }

    if (_dialplanProcess != null) {
      _log.info('Shutting down dialplan process');
      await _dialplanProcess.terminate();
    }

    if (_notificationProcess != null) {
      _log.info('Shutting down notification process');
      await _notificationProcess.terminate();
    }

    if (_authProcess != null) {
      _log.info('Shutting down authentication process');
      await _authProcess.terminate();
    }
  }

  /**
   *
   */
  Future finalize() async {
    await clear();
    if (_freeswitch != null) {
      _log.info('Terminating FreeSWITCH');
      await _freeswitch.terminate();
      _log.info('Deleting directory ${_freeswitch.basePath}');
      await new Directory(_freeswitch.basePath).deleteSync(recursive: true);
    }
    if (_httpClient != null) {
      _log.info('Terminating HttpClient');
      await _httpClient.client.close(force: true);
    }
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
  Future<Iterable<AuthToken>> get userTokens async {
    final uRefs = await userStore.list();

    return Future.wait(
        uRefs.map((uRef) async => new AuthToken(await userStore.get(uRef.id))));
  }

  /**
   *
   */
  Future removesServiceAgent(model.User serviceAgent) async {
    await _userStore.ready;
    await _userStore.remove(serviceAgent.id, _user);
  }
}
