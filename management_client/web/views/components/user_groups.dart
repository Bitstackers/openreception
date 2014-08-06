part of user.view;

class UserGroupContainer {
  TableElement _table;

  List<CheckboxInputElement> _checkboxs = [];
  List<UserGroup> _groupList = [], _userGroupList = [];

  UserGroupContainer(TableElement this._table) {
    refreshGroupList();
  }

  void refreshGroupList() {
    request.getGroupList().then((List<UserGroup> groups) {
      groups.sort((a, b) => a.name.compareTo(b.name));
      _groupList = groups;
      _renderBaseList();
    });
  }

  void _renderBaseList() {
    _checkboxs.clear();

    _table.children
      ..clear()
      ..addAll(_groupList.map(_makeGroupRow));
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

  void showNewUsersGroups() {
    _updateCheckBoxesWithUserGroup([]);
  }

  Future saveChanges(int userId) {
    List<int> inserts = [], removes = [];
    List<Future> worklist = [];

    for(CheckboxInputElement item in _checkboxs) {
      int id = int.parse(item.dataset['id']);
      bool userIsAMember = _userGroupList.any((g) => g.id == id);

      if(item.checked && !userIsAMember) {
        worklist.add(request.joinUserGroup(userId, id));

      } else if(!item.checked && userIsAMember) {
        worklist.add(request.leaveUserGroup(userId, id));
      }
    }
    return Future.wait(worklist);
  }
}
