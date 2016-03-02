part of management_tool.view;

class Dialplan {
  bool create = false;
  final ButtonElement _deleteButton = new ButtonElement()
    ..classes.add('delete')
    ..text = 'Slet'
    ..hidden = true;
  final controller.Dialplan _dialplanController;
  final TextAreaElement _dialplanInput = new TextAreaElement()
    ..classes.add('full-width')
    ..hidden = true
    ..value = '';
  final DivElement element = new DivElement()..classes = ['dialplan-view-widget'];
  final ButtonElement _foldJson = new ButtonElement()
    ..text = 'Fold sammen'
    ..classes.add('fold-unfold')
    ..hidden = true;
  final UListElement _inputErrorList = new UListElement();
  final Logger _log = new Logger('$_libraryName.Dialpan');
  final ButtonElement _saveButton = new ButtonElement()
    ..classes.add('save')
    ..text = 'Gem'
    ..hidden = true;
  final ButtonElement _unfoldJson = new ButtonElement()
    ..text = 'Fold ud'
    ..classes.add('fold-unfold')
    ..hidden = true;

  Function onUpdate = (String extension) => null;
  Function onDelete = (String extension) => null;
  Function onChange = () => null;

  Dialplan(this._dialplanController) {
    element.children = [
      _foldJson,
      _unfoldJson,
      _deleteButton,
      _saveButton,
      _inputErrorList,
      _dialplanInput
    ];
    _observers();
  }

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
        _inputErrorList.children.add(new LIElement()..text = 'Kaldplan-parser fejl.');
        _dialplanInput.classes.toggle('error', true);
      }
    } on FormatException {
      _inputErrorList.children.add(new LIElement()..text = 'JSON-parser fejl.');
      _dialplanInput.classes.toggle('error', true);
    }
  }

  Future _deleteDialplan() async {
    _log.finest('Deleting dialplan${dialplan.extension}');
    final String confirmationText = 'Bekræft sletning af kaldplan: ${dialplan.extension}}?';

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
      notify.error('Der skete en fejl i forbindelse med sletningen af kaldplanen',
          'Check at den ikke bruges af en reception.');
      _log.severe('Delete dialplan failed with: ${error}');
    }

    _deleteButton.text = 'Slet';
  }

  model.ReceptionDialplan get dialplan =>
      model.ReceptionDialplan.decode(JSON.decode(_dialplanInput.value));

  set dialplan(model.ReceptionDialplan rdp) {
    _dialplanInput.hidden = false;
    _dialplanInput.style.height = '';
    _dialplanInput.value = JSON.encode(rdp);
    _deleteButton.hidden = false;
    _foldJson.hidden = true;
    _saveButton.hidden = false;
    _unfoldJson.hidden = false;
    _checkInput();
    _saveButton.disabled = true;
    _deleteButton.disabled = !_saveButton.disabled || hasValidationError;

    /// Hack! To accomodate for the fact that hidden = false can take some time before "activating"
    new Future.delayed(new Duration(milliseconds: 100), () {
      _resizeInput();
    });
  }

  bool get hasValidationError => _dialplanInput.classes.contains('error');

  void _observers() {
    _saveButton.onClick.listen((_) async {
      if (create) {
        try {
          await _dialplanController.create(dialplan);
          notify.success('Kaldplan oprettet.', dialplan.extension);
        } catch (e, s) {
          _log.shout('Failed to create', e, s);
          notify.error('Kaldplan ikke oprettet.', dialplan.extension);
        }
      } else {
        try {
          await _dialplanController.update(dialplan);
          notify.success('Kaldplan opdateret.', dialplan.extension);
        } catch (e, s) {
          _log.shout('Failed to update', e, s);
          notify.error('Kaldplan ikke opdateret.', dialplan.extension);
        }
      }

      onUpdate != null ? onUpdate(dialplan.extension) : '';
    });

    _deleteButton.onClick.listen((_) => _deleteDialplan());

    _dialplanInput.onInput.listen((_) {
      _checkInput();

      _saveButton.disabled = hasValidationError;
      _deleteButton.disabled = !_saveButton.disabled || hasValidationError;

      onChange != null ? onChange() : '';
    });

    _unfoldJson.onClick.listen((_) {
      _unfoldJson.hidden = true;
      _foldJson.hidden = false;
      _dialplanInput.value = _jsonpp.convert(dialplan);
      _resizeInput();
    });

    _foldJson.onClick.listen((_) {
      _foldJson.hidden = true;
      _unfoldJson.hidden = false;
      _dialplanInput.style.height = '';
      _dialplanInput.value = JSON.encode(dialplan);
      _resizeInput();
    });
  }

  void _resizeInput() {
    while (_dialplanInput.client.height < _dialplanInput.scrollHeight) {
      _dialplanInput.style.height = '${_dialplanInput.client.height + 10}px';
    }
  }
}
