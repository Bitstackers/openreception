part of orm.view;

/**
 * View for usergroups checkbox group.
 */
class UserGroups {
  final controller.User _userController;
  final Logger _log = new Logger('$_libraryName.userGroups');

  final DivElement element = new DivElement();

  Function onChange = () => null;

  List<CheckboxInputElement> _checkboxs = new List<CheckboxInputElement>();
  final TableElement _table = new TableElement();
  Set<String> _allGroups = new Set<String>();
  Set<String> _originalGroups = new Set<String>();

  bool get isChanged => !isNotChanged;

  bool get isNotChanged =>
      _originalGroups.containsAll(groups.toSet()) &&
      groups.toSet().containsAll(_originalGroups);

  /**
   *
   */
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

    _checkboxs.forEach((cbx) {
      cbx.onChange.listen((e) {
        element.classes.toggle('changed', isChanged);

        if (onChange != null) {
          onChange();
        }
      });
    });
  }

  /**
   *
   */
  Future _refreshGroupList() async {
    /// Add valid groups to the set of available groups
    _allGroups = model.UserGroups.validGroups.toSet();

    /// Alternatively, fetch the groups from the server.
    //_allGroups = (await _userController.groups()).toSet();

    _renderBaseList();
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
    _originalGroups = gs.toSet();
    for (CheckboxInputElement checkbox in _checkboxs) {
      checkbox.checked =
          gs.any((String userGroup) => userGroup == checkbox.dataset['id']);
    }
  }

  /**
   * Clear out the input fields of the widget.
   */
  void clear() {
    for (CheckboxInputElement checkbox in _checkboxs) {
      checkbox.checked = false;
    }
  }
}
