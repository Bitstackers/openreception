part of usermon.view;

class AgentInfo {
  final or_model.User _user;

  int _numMessage = 0;

  int get numMessage => _numMessage;

  set numMessage (int count) {
    _numMessage = count;
    currentCallCell.text = '$_numMessage';
  }

  set agentStatistics(or_model.AgentStatistics stats) {
    statsCell.text = '${stats.total} kald i dag (${stats.recent} for nyligt)' ;
  }

  set userStatus(or_model.UserStatus status) {
    stateCell.text = '${status.state} (${status.lastState}})';
    String lastActivity = status.lastActivity != null
        ? '${new DateTime.now().difference(status.lastActivity).inSeconds}s'
        : 'Never';

    lastSeenCell.text = lastActivity;

    element.classes
      ..clear()
      ..add(status.state);
  }

  /**
   * Default constructor.
   */
  AgentInfo.fromModel(this._user) {
    ///Base data
    element.id = 'uid_${_user.ID}';
    nameCell.text = _user.name;

    ///Setup visual model.
    element.children = [
      nameCell,
      stateCell,
      currentCallCell,
      statsCell,
      lastSeenCell
    ];
  }

  final TableCellElement nameCell = new TableCellElement();
  final TableCellElement stateCell = new TableCellElement();
  final TableCellElement statsCell = new TableCellElement();
  final TableCellElement currentCallCell = new TableCellElement();
  final TableCellElement lastSeenCell = new TableCellElement();

  final TableRowElement element = new TableRowElement();
}