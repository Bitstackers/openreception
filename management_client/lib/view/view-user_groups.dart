part of management_tool.view;

class UserGroupChange {
  final Change type;
  final int groupId;

  UserGroupChange.join(this.groupId) : type = Change.added;
  UserGroupChange.leave(this.groupId) : type = Change.deleted;

  /**
   *
   */
  @override
  String toString() => '$type, gid:$groupId';
}

class UserGroups {
  final controller.User _userController;
  final Logger _log = new Logger('$_libraryName.userGroups');

  final DivElement element = new DivElement();

  Function onChange = () => null;

  List<CheckboxInputElement> _checkboxs = new List<CheckboxInputElement>();
  final TableElement _table = new TableElement();
  List<model.UserGroup> _allGroups = new List<model.UserGroup>();
  List<model.UserGroup> _originalGroups = new List<model.UserGroup>();

  UserGroups(this._userController) {
    element.children = [_table];
    _refreshGroupList();
  }

  /**
   *
   */
  TableRowElement _makeGroupRow(model.UserGroup group) {
    TableRowElement row = new TableRowElement();

    CheckboxInputElement checkbox = new CheckboxInputElement()
      ..id = 'grp_${group.id}'
      ..dataset['id'] = group.id.toString();
    _checkboxs.add(checkbox);

    TableCellElement checkCell = new TableCellElement()..children.add(checkbox);

    TableCellElement labelCell = new TableCellElement()
      ..children.add(new LabelElement()
        ..htmlFor = 'grp_${group.id}'
        ..text = group.name);

    return row..children.addAll([checkCell, labelCell]);
  }

  /**
   *
   */
  void _renderBaseList() {
    _checkboxs.clear();

    _table.children
      ..clear()
      ..addAll(_allGroups.map(_makeGroupRow));

    _checkboxs.forEach((cbx) => cbx.onChange.listen((e) {
          if (onChange != null) {
            onChange();
          }
        }));
  }

  /**
   *
   */
  void _refreshGroupList() {
    _userController.groups().then((Iterable<model.UserGroup> groups) {
      _allGroups = groups.toList();
      _renderBaseList();
    });
  }

  /**
   * Finds the groups the user should join/leave and sends the changes to the server.
   */
  Iterable<UserGroupChange> changes() {
    final List<UserGroupChange> changeList = [];

    for (CheckboxInputElement item in _checkboxs) {
      int groupId = int.parse(item.dataset['id']);
      bool userIsAMember =
          _originalGroups.any((model.UserGroup group) => group.id == groupId);

      if (item.checked && !userIsAMember) {
        changeList.add(new UserGroupChange.join(groupId));
      } else if (!item.checked && userIsAMember) {
        changeList.add(new UserGroupChange.leave(groupId));
      }
    }

    return changeList;
  }

  /**
   *
   */
  void set groups(Iterable<model.UserGroup> gs) {
    _originalGroups = gs.toList(growable: false);
    for (CheckboxInputElement checkbox in _checkboxs) {
      checkbox.checked = gs.any((model.UserGroup userGroup) =>
          userGroup.id == int.parse(checkbox.dataset['id']));
    }
  }
}
