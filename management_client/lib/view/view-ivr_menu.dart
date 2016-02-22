part of management_tool.view;

class IvrMenu {
  final DivElement element = new DivElement()
    ..classes = ['ivrmenu-view-widget']
    ..hidden = true;

  final Logger _log = new Logger('$_libraryName.IvrMenu');

  bool get hasValidationError => _menuInput.classes.contains('error');
  final UListElement _inputErrorList = new UListElement();
  bool create = false;

  Function onUpdate = (String extension) => null;
  Function onDelete = (String extension) => null;

  final TextAreaElement _menuInput = new TextAreaElement()
    ..classes.add('full-width')
    ..style.height = '24em'
    ..value = '';

  final ButtonElement _deleteButton = new ButtonElement()
    ..classes.add('delete')
    ..text = 'Slet';

  final ButtonElement _saveButton = new ButtonElement()
    ..classes.add('save')
    ..text = 'Gem';

  final controller.Ivr _menuController;

  /**
   *
   */
  set menu(model.IvrMenu menu) {
    _menuInput.value = _jsonpp.convert(menu);
    element.hidden = false;
    _checkInput();
    _saveButton.disabled = true;
    _deleteButton.disabled = !_saveButton.disabled || hasValidationError;
  }

  /**
   *
   */
  void _checkInput() {
    model.IvrMenu menu;
    Map json;
    _inputErrorList.children.clear();
    _menuInput.classes.toggle('error', false);
    try {
      json = JSON.decode(_menuInput.value);

      try {
        menu = model.IvrMenu.decode(json);
      } on FormatException {
        _inputErrorList.children
            .add(new LIElement()..text = 'Kaldplan-parser fejl.');
        _menuInput.classes.toggle('error', true);
      }
    } on FormatException {
      _inputErrorList.children.add(new LIElement()..text = 'JSON-parser fejl.');
      _menuInput.classes.toggle('error', true);
    }
  }

  /**
   *
   */
  model.IvrMenu get menu => model.IvrMenu.decode(JSON.decode(_menuInput.value));

  /**
   *
   */
  void _observers() {
    _saveButton.onClick.listen((_) async {
      if (create) {
        try {
          await _menuController.create(menu);
          notify.success('IVR-Menu blev oprettet.', menu.name);
        } catch (e, s) {
          _log.shout('Failed to create', e, s);
          notify.error('IVR-Menu blev ikke oprettet.', menu.name);
        }
      } else {
        try {
          await _menuController.update(menu);
          notify.success('IVR-Menu blev opdateret.', menu.name);
        } catch (e, s) {
          _log.shout('Failed to update', e, s);
          notify.error('IVR-Menu blev ikke opdateret.', menu.name);
        }
      }

      onUpdate != null ? onUpdate(menu.name) : '';
    });

    _deleteButton.onClick.listen((_) => _deleteMenu());

    _menuInput.onInput.listen((_) {
      _checkInput();

      _saveButton.disabled = hasValidationError;
      _deleteButton.disabled = !_saveButton.disabled || hasValidationError;
    });
  }

  /**
     *
     */
  Future _deleteMenu() async {
    _log.finest('Deleting menu ${menu.name}');
    final String confirmationText = 'Bekræft sletning af menu: ${menu.name}}?';

    if (_deleteButton.text != confirmationText) {
      _deleteButton.text = confirmationText;
      return;
    }

    try {
      _deleteButton.disabled = true;

      await _menuController.remove(menu.name);
      notify.success('Menuen er slettet.', menu.name);

      onDelete != null ? onDelete(menu.name) : '';

      /// Cleanup element.
      _menuInput.value = '';
      element.hidden = true;
    } catch (error) {
      notify.error('Der skete en fejl i forbindelse med sletningen af menuen.',
          'Fejl: $error');
      _log.severe('Delete ivrmenu failed with: ${error}');
    }

    _deleteButton.text = 'Slet';
  }

  /**
    *
    */
  IvrMenu(this._menuController) {
    element.children = [
      _deleteButton,
      _saveButton,
      _inputErrorList,
      _menuInput
    ];
    _observers();
  }
}
