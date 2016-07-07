part of management_tool.view.agent_monitoring;

class AgentInfo {
  final model.UserReference _user;

  final SpanElement _messageElement = new SpanElement()
    ..classes.add('message')
    ..text = '[0]'
    ..style.textTransform = 'bold';

  final TableCellElement _nameCell = new TableCellElement()
    ..classes.add('name');
  final TableCellElement _stateCell = new TableCellElement();
  final TableCellElement _widgetCell = new TableCellElement();

  final TableCellElement _focusCell = new TableCellElement();
  final SpanElement _focusCellText = new SpanElement();
  final SpanElement _focusCellAge = new SpanElement();

  final TableCellElement _focusAgeCell = new TableCellElement();
  final TableCellElement _statsCell = new TableCellElement();

  final TableCellElement currentCallCell = new TableCellElement();
  final TableCellElement lastSeenCell = new TableCellElement();

  final ImageElement _userStateIcon =
      new ImageElement(src: _unknownImgPath, width: 16, height: 16);

  static String get _unknownImgPath => 'images/agent_unknown.svg';
  static String get _pauseImgPath => 'images/agent_pause.svg';
  static String get _idleImgPath => 'images/agent_idle.svg';
  static String get _speakingImgPath => 'images/agent_speaking.svg';

  DateTime _focusChangeTimestamp = new DateTime.fromMillisecondsSinceEpoch(0);

  final TableRowElement element = new TableRowElement();
  int _numMessage = 0;

  int get numMessage => _numMessage;
  Set<String> _callshandled = new Set();

  /**
   *
   */
  set numMessage(int count) {
    _numMessage = count;
    currentCallCell.text = '$_numMessage';
  }

  set focus(bool inFocus) {
    _focusChangeTimestamp = new DateTime.now();
    _focusCellText.text = '${inFocus ? 'I fokus' : 'Ikke i fokus'}';
    element.classes.toggle('blur', !inFocus);
    tick();
  }

  set widget(String widgetName) {
    _widgetCell.text = widgetName;
  }

  /**
   *
   */
  set agentStatistics(model.AgentStatistics stats) {
    _statsCell.text = '${stats.total} kald i dag (${stats.recent} for nyligt)';
  }

  /**
   *
   */
  set call(model.Call c) {
    _callshandled.add(c.id);
    if (c.state == model.CallState.hungup ||
        c.state == model.CallState.transferred) {
      currentCallCell.text = '';

      _updateStats();
    } else {
      currentCallCell.text = c.callerId;
    }
  }

  /**
   *
   */
  void tick() {
    final String text = _focusChangeTimestamp.millisecondsSinceEpoch == 0
        ? '-'
        : _prettyDuration(new DateTime.now().difference(_focusChangeTimestamp));

    _focusAgeCell.text = text;
  }

  /**
   *
   */
  _updateStats() {
    _statsCell.text = 'Håndterede kald: ${_callshandled.length}';
  }

  set paused(bool isPaused) {
    if (isPaused) {
      _userStateIcon.src = _pauseImgPath;
    } else {
      _userStateIcon.src = _idleImgPath;
    }

    lastSeenCell.text = '??';

    element.classes
      ..clear()
      ..add('speaking');
  }

  /**
   * Default constructor.
   */
  AgentInfo.fromModel(this._user) {
    ///Base data
    _nameCell.text = _user.name;

    ///Setup visual model.
    element.children = [
      _stateCell..children = [_userStateIcon],
      _nameCell,
      _widgetCell,
      _focusCell..children = [_focusCellText, _focusAgeCell]
    ];
  }
}

/**
 * Prettyfy duration.
 */
String _prettyDuration(Duration d) {
  final int h = d.inHours;
  final int m = d.inMinutes % 60;
  final int s = d.inSeconds % 60;

  if (h > 0) {
    return '${h}:${m}:${s}s';
  } else if (m > 0) {
    if (s < 10) {
      return '${m}:0${s}s';
    } else {
      return '${m}:${s}s';
    }
    return '${m}:${s}s';
  } else {
    return '${s}s';
  }
}
