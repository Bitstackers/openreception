part of management_tool.view;

class ReceptionContactChange {
  final Change type;
  final model.Contact contact;

  ReceptionContactChange.create(this.contact) : type = Change.created;
  ReceptionContactChange.delete(this.contact) : type = Change.deleted;
  ReceptionContactChange.update(this.contact) : type = Change.updated;
}

class ReceptionContact {
  final bool _single; // Are we alone in the list?
  final controller.Reception _receptionController;
  final controller.Contact _contactController;
  final controller.Endpoint _endpointController;
  final controller.DistributionList _dlistController;

  ///TODO: Add additional validation checks
  bool get inputHasErrors =>
      _endpointsView.validationError ||
      _distributionsListView.validationError ||
      _phoneNumberView.validationError;

  final HeadingElement _header = new HeadingElement.h2()
    ..classes.add('reception-contact-header');

  final TextInputElement _ridInput = new TextInputElement()
    ..value = model.Reception.noID.toString()
    ..hidden = true;

  final TextInputElement _cidInput = new TextInputElement()
    ..value = model.Contact.noID.toString()
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
  DistributionList _distributionsListView;
  Phonenumbers _phoneNumberView;

  /**
   *
   */
  ReceptionContact(this._receptionController, this._contactController,
      this._endpointController, this._dlistController, bool this._single) {
    if (!_single) {
      element.style.height = '45px';
    }

    _endpointsView = new Endpoints(_contactController, _endpointController);

    _distributionsListView = new DistributionList();

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
          _distributionsListView.element,
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
        await _contactController.updateInReception(contact);
        _saveButton.disabled = inputHasErrors;
        _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;

        try {
          await Future.wait(_endpointsView.endpointChanges.map((epc) async {
            if (epc.type == Change.created) {
              await _endpointController.create(
                  contact.receptionID, contact.ID, epc.endpoint);
            } else if (epc.type == Change.deleted) {
              await _endpointController.remove(epc.endpoint.id);
            } else if (epc.type == Change.updated) {
              await _endpointController.update(epc.endpoint);
            } else {
              throw new ArgumentError('Bad type of change : ${epc.type}');
            }
          }));
        } catch (e) {
          notify.error('Beskedadresser ikke opdateret', 'Fejl: $e');
        }

        try {
          await Future.wait(
              _distributionsListView.distributionListChanges.map((dlc) async {
            if (dlc.type == Change.created) {
              await _dlistController.addRecipient(
                  contact.receptionID, contact.ID, dlc.entry);
            } else if (dlc.type == Change.deleted) {
              await _dlistController.removeRecipient(dlc.entry.id);
            } else {
              throw new ArgumentError('Bad type of change : ${dlc.type}');
            }
          }));
        } catch (e) {
          notify.error('Distributionsliste ikke opdateret', 'Fejl: $e');
        }

        notify.success('Receptions-kontakten blev opdateret', contact.fullName);
      } catch (error) {
        notify.error('Receptions-kontakten blev ikke opdateret', 'Fejl:$error');
      }

      /// Reload the contact.
      contact = await _contactController.getByReception(
          contact.ID, contact.receptionID);
    });

    _deleteButton.onClick.listen((_) async {
      final String confirmText = 'Bekræft fjernelse af ${contact.fullName} fra '
          'receptionen ${_header.text}';

      if (_deleteButton.text != confirmText) {
        _deleteButton.text = confirmText;
        return;
      }

      try {
        await _contactController.removeFromReception(
            contact.ID, contact.receptionID);
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

    _distributionsListView.onChange = () {
      _saveButton.disabled = inputHasErrors;
      _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;
    };

    _phoneNumberView.onChange = () {
      _saveButton.disabled = inputHasErrors;
      _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;
    };
  }

  model.Contact get contact => new model.Contact.empty()
    ..ID = int.parse(_cidInput.value)
    ..receptionID = int.parse(_ridInput.value)
    ..backupContacts = _valuesFromListTextArea(_backupContactsInput)
    ..departments = _valuesFromListTextArea(_departmentsInput)
    ..emailaddresses = _valuesFromListTextArea(_emailAddessesInput)
    ..handling = _valuesFromListTextArea(_handlingInput)
    ..infos = _valuesFromListTextArea(_infoInput)
    ..messagePrerequisites = _valuesFromListTextArea(_messagePrerequisiteInput)
    ..relations = _valuesFromListTextArea(_relationsInput)
    ..responsibilities = _valuesFromListTextArea(_responsibilitiesInput)
    ..statusEmail = _statusEmailInput.checked
    ..tags = _valuesFromListTextArea(_tagsInput).toSet().toList(growable: false)
    ..titles = _valuesFromListTextArea(_titlesInput)
    ..workhours = _valuesFromListTextArea(_workHoursInput)
    ..phones = _phoneNumberView.phoneNumbers.toList();

  void set contact(model.Contact contact) {
    _ridInput.value = contact.receptionID.toString();
    _cidInput.value = contact.ID.toString();

    _tagsInput.value = contact.tags.join('\n');
    _statusEmailInput.checked = contact.wantsMessage;
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

    _endpointController.list(contact.receptionID, contact.ID).then((eps) {
      _endpointsView.endpoints = eps;
    });

    _dlistController.list(contact.receptionID, contact.ID).then((dlist) {
      _distributionsListView.distributionList = dlist;
      _distributionsListView.owner = contact;
    });

    _receptionController.get(contact.receptionID).then((model.Reception r) {
      _header.text = '${r.name} (rid: ${r.ID})';
      _distributionsListView.receptionName = r.name;
    });

    _deleteButton.disabled = !_saveButton.disabled;
  }
}
