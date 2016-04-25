part of management_tool.view;

class ReceptionContact {
  final bool _single; // Are we alone in the list?
  final controller.Reception _receptionController;
  final controller.Contact _contactController;

  ///TODO: Add additional validation checks
  bool get inputHasErrors =>
      _endpointsView.validationError || _phoneNumberView.validationError;

  final HeadingElement _header = new HeadingElement.h2()
    ..classes.add('reception-contact-header');

  final TextInputElement _ridInput = new TextInputElement()
    ..value = model.Reception.noId.toString()
    ..hidden = true;

  final TextInputElement _cidInput = new TextInputElement()
    ..value = model.BaseContact.noId.toString()
    ..hidden = true;

  final ButtonElement _saveButton = new ButtonElement()
    ..text = 'Gem'
    ..disabled = true
    ..classes.add('save');

  final ButtonElement _deleteButton = new ButtonElement()
    ..text = 'Slet'
    ..disabled = true
    ..classes.add('delete');

  final LIElement element = new LIElement()..classes.add('contact-reception');

  final TextAreaElement _backupContactsInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _departmentsInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _emailAddessesInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _handlingInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _infoInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _messagePrerequisiteInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _relationsInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _responsibilitiesInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _tagsInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _titlesInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _workHoursInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final CheckboxInputElement _statusEmailInput = new CheckboxInputElement()
    ..checked = true;

  Endpoints _endpointsView;
  Phonenumbers _phoneNumberView;

  /**
   *
   */

  ReceptionContact(
      this._receptionController, this._contactController, bool this._single) {
    if (!_single) {
      element.style.height = '45px';
    }

    _endpointsView = new Endpoints(_contactController);

    _phoneNumberView = new Phonenumbers();

    element.children = [
      _header,
      _saveButton,
      _deleteButton,
      _ridInput,

      new DivElement()
        ..children = [
          new LabelElement()..text = 'Ønsker statusmails',
          _statusEmailInput
        ],

      /// Left column.
      new DivElement()
        ..classes.add('col-1-2')
        ..children = [
          _endpointsView.element,
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Emailadresser'
                ..htmlFor = _emailAddessesInput.id,
              _emailAddessesInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Kommandoer'
                ..htmlFor = _handlingInput.id,
              _handlingInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Arbejdstider'
                ..htmlFor = _workHoursInput.id,
              _workHoursInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Backup kontakter'
                ..htmlFor = _backupContactsInput.id,
              _backupContactsInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Ansvarsomåder'
                ..htmlFor = _responsibilitiesInput.id,
              _responsibilitiesInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Tags'
                ..htmlFor = _tagsInput.id,
              _tagsInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Info'
                ..htmlFor = _infoInput.id,
              _infoInput
            ],
        ],

      /// Right column.
      new DivElement()
        ..classes.add('col-1-2')
        ..children = [
          _phoneNumberView.element,
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Beskedinstrukser'
                ..htmlFor = _messagePrerequisiteInput.id,
              _messagePrerequisiteInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Titler'
                ..htmlFor = _titlesInput.id,
              _titlesInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Relationer'
                ..htmlFor = _relationsInput.id,
              _relationsInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Afdelinger'
                ..htmlFor = _departmentsInput.id,
              _departmentsInput
            ],
        ],
      new DivElement()
        ..text = '.'
        ..style.color = 'white'
    ];

    _observers();
  }

  void _observers() {
    _header.onClick.listen((_) {
      if (element.client.height > 45) {
        element.style.height = '45px';
      } else {
        element.style.height = '';
      }
    });

    _saveButton.onClick.listen((_) async {
      try {
        await _contactController.updateInReception(attributes);
        _saveButton.disabled = inputHasErrors;
        _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;

        notify.success('Receptions-kontakten blev opdateret',
            '');
      } catch (error) {
        notify.error('Receptions-kontakten blev ikke opdateret', 'Fejl:$error');
      }

      /// Reload the contact.
      attributes = await _contactController.getByReception(
          attributes.contactId, attributes.receptionId);
    });

    _deleteButton.onClick.listen((_) async {
      final String confirmText =
          'Bekræft fjernelse fra receptionen ${_header.text}';

      if (_deleteButton.text != confirmText) {
        _deleteButton.text = confirmText;
        return;
      }

      try {
        await _contactController.removeFromReception(
            attributes.contactId, attributes.receptionId);
        notify.success(
            'Receptions-kontakt fjernet fra reception', '${_header.text}');
        element.remove();
      } catch (error) {
        notify.error('Receptions-kontakten ikke fjernet', 'Fejl: $error');
      }
    });

    Iterable<Element> inputs = element.querySelectorAll('input,textarea');

    inputs.forEach((Element ine) {
      ine.onInput.listen((_) {
        _saveButton.disabled = inputHasErrors;
        _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;
      });
    });

    _statusEmailInput.onChange.listen((_) {
      _saveButton.disabled = inputHasErrors;
      _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;
    });

    _endpointsView.onChange = () {
      _saveButton.disabled = inputHasErrors;
      _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;
    };

    _phoneNumberView.onChange = () {
      _saveButton.disabled = inputHasErrors;
      _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;
    };
  }

  model.ReceptionAttributes get attributes =>
      new model.ReceptionAttributes.empty()
        ..endpoints = _endpointsView.endpoints.toList(growable: false)
        ..contactId = int.parse(_cidInput.value)
        ..receptionId = int.parse(_ridInput.value)
        ..backupContacts = _valuesFromListTextArea(_backupContactsInput)
        ..departments = _valuesFromListTextArea(_departmentsInput)
        ..emailaddresses = _valuesFromListTextArea(_emailAddessesInput)
        ..handling = _valuesFromListTextArea(_handlingInput)
        ..infos = _valuesFromListTextArea(_infoInput)
        ..messagePrerequisites =
            _valuesFromListTextArea(_messagePrerequisiteInput)
        ..relations = _valuesFromListTextArea(_relationsInput)
        ..responsibilities = _valuesFromListTextArea(_responsibilitiesInput)
        ..statusEmail = _statusEmailInput.checked
        ..tags =
            _valuesFromListTextArea(_tagsInput).toSet().toList(growable: false)
        ..titles = _valuesFromListTextArea(_titlesInput)
        ..workhours = _valuesFromListTextArea(_workHoursInput)
        ..phones = _phoneNumberView.phoneNumbers.toList();

  void set attributes(model.ReceptionAttributes contact) {
    _ridInput.value = contact.receptionId.toString();
    _cidInput.value = contact.contactId.toString();

    _tagsInput.value = contact.tags.join('\n');
    _statusEmailInput.checked = contact.statusEmail;
    _backupContactsInput.value = contact.backupContacts.join('\n');
    _handlingInput.value = contact.handling.join('\n');
    _departmentsInput.value = contact.departments.join('\n');
    _infoInput.value = contact.infos.join('\n');
    _titlesInput.value = contact.titles.join('\n');
    _relationsInput.value = contact.relations.join('\n');
    _responsibilitiesInput.value = contact.responsibilities.join('\n');
    _emailAddessesInput.value = contact.emailaddresses.join('\n');
    _messagePrerequisiteInput.value = contact.messagePrerequisites.join('\n');

    _phoneNumberView.phoneNumbers = contact.phones;
    _workHoursInput.value = contact.workhours.join('\n');

    _endpointsView.endpoints = contact.endpoints;

    _receptionController.get(contact.receptionId).then((model.Reception r) {
      _header.text = '${r.name} (rid: ${r.id})';
    });

    _deleteButton.disabled = !_saveButton.disabled;
  }
}
