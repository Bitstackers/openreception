part of user.view;

class UserGroupContainer {
  final Controller.User _userController;

  List<CheckboxInputElement> _checkboxs = new List<CheckboxInputElement>();
  TableElement _table;
  List<ORModel.UserGroup> _groupList     = new List<ORModel.UserGroup>();
  List<ORModel.UserGroup> _userGroupList = new List<ORModel.UserGroup>();

  UserGroupContainer(TableElement this._table, Controller.User this._userController) {
    refreshGroupList();
  }

  TableRowElement _makeGroupRow(ORModel.UserGroup group) {
    TableRowElement row = new TableRowElement();

    CheckboxInputElement checkbox = new CheckboxInputElement()
      ..id = 'grp_${group.id}'
      ..dataset['id'] = group.id.toString();
    _checkboxs.add(checkbox);

    TableCellElement checkCell = new TableCellElement()
      ..children.add(checkbox);

    TableCellElement labelCell = new TableCellElement()
      ..children.add(new LabelElement()
        ..htmlFor = 'grp_${group.id}'
        ..text = group.name);

    return row
      ..children.addAll([checkCell, labelCell]);
  }

  void _renderBaseList() {
    _checkboxs.clear();

    _table.children
      ..clear()
      ..addAll(_groupList.map(_makeGroupRow));
  }

  void refreshGroupList() {
    _userController.groups().then((Iterable<ORModel.UserGroup> groups) {
      _groupList = groups.toList();
      _renderBaseList();
    });
  }

  /**
   * Finds the groups the user should join/leave and sends the changes to the server.
   */
  Future saveChanges(int userId) {
    List<int> inserts = new List<int>();
    List<int> removes = new List<int>();
    List<Future> worklist = new List<Future>();

    for(CheckboxInputElement item in _checkboxs) {
      int groupId = int.parse(item.dataset['id']);
      bool userIsAMember = _userGroupList.any((ORModel.UserGroup group) => group.id == groupId);

      if(item.checked && !userIsAMember) {
        worklist.add(_userController.joinGroup(userId, groupId)
            .catchError((error, stack) {
          log.error('Request for user to join a group failed. UserId: "${userId}". GroupId: "${groupId}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));

      } else if(!item.checked && userIsAMember) {
        worklist.add(_userController.leaveGroup(userId, groupId)
            .catchError((error, stack) {
          log.error('Request for user to leave a group failed. UserId: "${userId}". GroupId: "${groupId}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }
    return Future.wait(worklist);
  }

  void showNewUsersGroups() {
    _updateCheckBoxesWithUserGroup(new List<ORModel.UserGroup>());
  }

  Future showUsersGroups(int userId) {
    return _userController.userGroups(userId).then((Iterable<ORModel.UserGroup> groups) {
      _updateCheckBoxesWithUserGroup(groups);
    });
  }

  void _updateCheckBoxesWithUserGroup(Iterable<ORModel.UserGroup> groups) {
    _userGroupList = groups.toList();
    for(CheckboxInputElement checkbox in _checkboxs) {
      checkbox.checked = groups.any((ORModel.UserGroup userGroup) => userGroup.id == int.parse(checkbox.dataset['id']));
    }
  }
}
