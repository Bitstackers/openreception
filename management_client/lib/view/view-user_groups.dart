part of management_tool.view;

class UserGroupChange {
  final Change type;
  final int uid;
  final model.UserGroup group;

  UserGroupChange.added(this.uid, this.group) : type = Change.added;
  UserGroupChange.delete(this.uid, this.group) : type = Change.deleted;
}

class UserGroups {
  final controller.User _userController;
  final Logger _log = new Logger('$_libraryName.userGroups');

  final DivElement element = new DivElement();

  Stream<UserGroupChange> get changes => _changeBus.stream;
  final Bus<UserGroupChange> _changeBus = new Bus<UserGroupChange>();

  List<CheckboxInputElement> _checkboxs = new List<CheckboxInputElement>();
  final TableElement _table = new TableElement();
  List<model.UserGroup> _groupList = new List<model.UserGroup>();

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
      ..addAll(_groupList.map(_makeGroupRow));
  }

  /**
   *
   */
  void _refreshGroupList() {
    _userController.groups().then((Iterable<model.UserGroup> groups) {
      _groupList = groups.toList();
      _renderBaseList();
    });
  }

  /**
   *
   */
  void set groups(Iterable<model.UserGroup> gs) {
    for (CheckboxInputElement checkbox in _checkboxs) {
      checkbox.checked = gs.any((model.UserGroup userGroup) =>
          userGroup.id == int.parse(checkbox.dataset['id']));
    }
  }
}
