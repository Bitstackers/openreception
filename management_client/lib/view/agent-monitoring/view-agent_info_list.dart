part of management_tool.view.agent_monitoring;

class AgentInfoList {
  Map<int, AgentInfo> _info = {};
  final controller.Call _callController;
  final List<model.Call> _callCache = [];

  final controller.User _userController;

  final Map<int, model.UserReference> _userCache = {};

  final DivElement element = new DivElement();

  TableSectionElement _tableBody = new TableElement().createTBody();

  /**
   *
   */
  AgentInfoList(
      this._callController,
      this._userController,
      Stream<event.UserState> userStateChange,
      Stream<event.PeerState> peerStateChange,
      Stream<event.WidgetSelect> widgetSelect,
      Stream<event.FocusChange> focusChange) {
    element.children = [_tableBody];

    userStateChange.listen((event.UserState e) {
      _info[e.status.userId].paused = e.status.paused;
    });

    widgetSelect.listen((event.WidgetSelect e) {
      _info[e.uid].widget = e.widgetName;
    });

    focusChange.listen((event.FocusChange e) {
      _info[e.uid].focus = e.inFocus;
    });

    new Timer.periodic(new Duration(milliseconds: 300), (_) {
      _info.values.forEach((i) => i.tick());
    });
  }

  /**
   *
   */
  Future render() async {
    if (_userCache.isEmpty) {
      Iterable<model.UserReference> users = await _userController.list();

      for (model.UserReference user in users) {
        _userCache[user.id] = user;
      }
    }

    ///TODO: Load call cache.

    _tableBody.children = _userCache.values.map((user) {
      _info[user.id] = new AgentInfo.fromModel(user);

      return _info[user.id].element;
    }).toList(growable: false);

    /// Fetch initial user status
    await _userController
        .userStatusList()
        .then((Iterable<model.UserStatus> statuses) {
      statuses.forEach((status) {
        _info[status.userId].paused = status.paused;
      });
    });
  }
}
