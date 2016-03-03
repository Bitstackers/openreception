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
  List<String> _allGroups = new List<String>();
  List<String> _originalGroups = new List<String>();

  UserGroups(this._userController) {
    element.children = [_table];
    _refreshGroupList();
  }

  /**
   *
   */
  TableRowElement _makeGroupRow(String group) {
    TableRowElement row = new TableRowElement();

    CheckboxInputElement checkbox = new CheckboxInputElement()
      ..id = 'grp_${group}'
      ..dataset['id'] = group;
    _checkboxs.add(checkbox);

    TableCellElement checkCell = new TableCellElement()..children.add(checkbox);

    TableCellElement labelCell = new TableCellElement()
      ..children.add(new LabelElement()
        ..htmlFor = 'grp_${group}'
        ..text = group);

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
    _userController.groups().then((Iterable<String> groups) {
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
          _originalGroups.any((String group) => group == groupId);

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
  Iterable<String> get groups {
    return _checkboxs
        .where((box) => box.checked)
        .map((box) => box.dataset['id']);
  }

  /**
   *
   */
  void set groups(Iterable<String> gs) {
    _originalGroups = gs.toList(growable: false);
    for (CheckboxInputElement checkbox in _checkboxs) {
      checkbox.checked =
          gs.any((String userGroup) => userGroup == checkbox.dataset['id']);
    }
  }
}
