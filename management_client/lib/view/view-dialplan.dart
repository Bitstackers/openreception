part of management_tool.view;

class Dialplan {
  final DivElement element = new DivElement()
    ..classes = ['dialplan-view-widget']
    ..hidden = true;

  final Logger _log = new Logger('$_libraryName.Dialpan');

  bool get hasValidationError => _dialplanInput.classes.contains('error');
  final UListElement _inputErrorList = new UListElement();

  Function onUpdate = (String extension) => null;
  Function onDelete = (String extension) => null;

  final TextAreaElement _dialplanInput = new TextAreaElement()
    ..classes.add('full-width')
    ..style.height = '24em'
    ..value = '';

  final ButtonElement _deleteButton = new ButtonElement()
    ..classes.add('delete')
    ..text = 'Slet';

  final ButtonElement _saveButton = new ButtonElement()
    ..classes.add('save')
    ..text = 'Gem';

  final controller.Dialplan _dialplanController;

  /**
   *
   */
  set dialplan(model.ReceptionDialplan rdp) {
    _dialplanInput.value = _jsonpp.convert(rdp);
    element.hidden = false;
    _checkInput();
    _saveButton.disabled = true;
    _deleteButton.disabled = !_saveButton.disabled || hasValidationError;
  }

  /**
   *
   */
  void _checkInput() {
    model.ReceptionDialplan rdp;
    Map json;
    _inputErrorList.children.clear();
    _dialplanInput.classes.toggle('error', false);
    try {
      json = JSON.decode(_dialplanInput.value);

      try {
        rdp = model.ReceptionDialplan.decode(json);
      } on FormatException {
        _inputErrorList.children
            .add(new LIElement()..text = 'Kaldplan-parser fejl.');
        _dialplanInput.classes.toggle('error', true);
      }
    } on FormatException {
      _inputErrorList.children.add(new LIElement()..text = 'JSON-parser fejl.');
      _dialplanInput.classes.toggle('error', true);
    }
  }

  /**
   *
   */
  model.ReceptionDialplan get dialplan =>
      model.ReceptionDialplan.decode(JSON.decode(_dialplanInput.value));

  /**
   *
   */
  void _observers() {
    _saveButton.onClick.listen((_) async {
      await _dialplanController.update(dialplan);
      onUpdate != null ? onUpdate(dialplan.extension) : '';
      notify.success('Kaldplan blev opdateret.', dialplan.extension);
    });

    _deleteButton.onClick.listen((_) => _deleteDialplan());

    _dialplanInput.onInput.listen((_) {
      _checkInput();

      _saveButton.disabled = hasValidationError;
      _deleteButton.disabled = !_saveButton.disabled || hasValidationError;
    });
  }

  /**
     *
     */
  Future _deleteDialplan() async {
    _log.finest('Deleting dialplan${dialplan.extension}');
    final String confirmationText =
        'Bekræft sletning af kaldplan: ${dialplan.extension}}?';

    if (_deleteButton.text != confirmationText) {
      _deleteButton.text = confirmationText;
      return;
    }

    try {
      _deleteButton.disabled = true;

      await _dialplanController.remove(dialplan.extension);
      notify.success('Kaldplan er slettet.', dialplan.extension);

      onDelete != null ? onDelete(dialplan.extension) : '';

      /// Cleanup element.
      _dialplanInput.value = '';
      element.hidden = true;
    } catch (error) {
      notify.error(
          'Der skete en fejl i forbindelse med sletningen af kaldplanen',
          'Check at den ikke bruges af en reception.');
      _log.severe('Delete dialplan failed with: ${error}');
    }

    _deleteButton.text = 'Slet';
  }

  /**
    *
    */
  Dialplan(this._dialplanController) {
    element.children = [
      _deleteButton,
      _saveButton,
      _inputErrorList,
      _dialplanInput
    ];
    _observers();
  }
}
