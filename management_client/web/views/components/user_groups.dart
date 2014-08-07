part of user.view;

class UserGroupContainer {
  List<CheckboxInputElement> _checkboxs = [];
  TableElement _table;
  List<UserGroup> _groupList = [], _userGroupList = [];

  UserGroupContainer(TableElement this._table) {
    refreshGroupList();
  }

  TableRowElement _makeGroupRow(UserGroup group) {
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
    request.getGroupList().then((List<UserGroup> groups) {
      groups.sort();
      _groupList = groups;
      _renderBaseList();
    });
  }

  /**
   * Finds the groups the user should join/leave and sends the changes to the server.
   */
  Future saveChanges(int userId) {
    List<int> inserts = [], removes = [];
    List<Future> worklist = [];

    for(CheckboxInputElement item in _checkboxs) {
      int groupId = int.parse(item.dataset['id']);
      bool userIsAMember = _userGroupList.any((UserGroup group) => group.id == groupId);

      if(item.checked && !userIsAMember) {
        worklist.add(request.joinUserGroup(userId, groupId)
            .catchError((error, stack) {
          log.error('Request for user to join a group failed. UserId: "${userId}". GroupId: "${groupId}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));

      } else if(!item.checked && userIsAMember) {
        worklist.add(request.leaveUserGroup(userId, groupId)
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
    _updateCheckBoxesWithUserGroup([]);
  }

  Future showUsersGroups(int userId) {
    return request.getUsersGroup(userId).then((List<UserGroup> groups) {
      _updateCheckBoxesWithUserGroup(groups);
    });
  }

  void _updateCheckBoxesWithUserGroup(List<UserGroup> groups) {
    _userGroupList = groups;
    for(CheckboxInputElement checkbox in _checkboxs) {
      checkbox.checked = groups.any((UserGroup userGroup) => userGroup.id == int.parse(checkbox.dataset['id']));
    }
  }
}
