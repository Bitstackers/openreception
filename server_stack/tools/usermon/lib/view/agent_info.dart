part of usermon.view;

class AgentInfo {
  final model.User _user;

  int _numMessage = 0;

  int get numMessage => _numMessage;
  Set<String> _callshandled = new Set();

  set numMessage(int count) {
    _numMessage = count;
    currentCallCell.text = '$_numMessage';
  }

  set agentStatistics(model.AgentStatistics stats) {
    _statsCell.text = '${stats.total} kald i dag (${stats.recent} for nyligt)';
  }

  set call(model.Call c) {
    _callshandled.add(c.ID);
    if (c.state == model.CallState.Hungup ||
        c.state == model.CallState.Transferred) {
      currentCallCell.text = '';

      _updateStats();
    } else {
      currentCallCell.text = c.callerID;
    }
  }

  _updateStats() {
    _statsCell.text = 'Håndterede kald: ${_callshandled.length}';
  }

  set userStatus(model.UserStatus status) {
    _stateCell.text = '${status.paused ? 'paused' : 'active'}';

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
      new TableCellElement()
        ..children = [
          new DivElement()..classes.add('status'),
          _nameCell,
          _statsCell
            ..children = [
              new DivElement()
                ..classes.add('stick')
                ..children = [
                  _messageElement,
                  new ImageElement()
                    ..src = 'img/stick_left.png'
                    ..classes.add('stick_left'),
                  new ImageElement()
                    ..src = 'img/stick_right.png'
                    ..classes.add('stick_right')
                ]
            ]
        ]
    ];
  }

  final SpanElement _messageElement = new SpanElement()
    ..classes.add('message')
    ..text = '[0]'
    ..style.textTransform = 'bold';

  final TableCellElement _nameCell = new TableCellElement()
    ..classes.add('name');
  final TableCellElement _stateCell = new TableCellElement();
  final TableCellElement _statsCell = new TableCellElement();
  final TableCellElement currentCallCell = new TableCellElement();
  final TableCellElement lastSeenCell = new TableCellElement();

  final TableRowElement element = new TableRowElement();
}
