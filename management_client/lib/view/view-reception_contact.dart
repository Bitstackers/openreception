part of management_tool.view;

class ReceptionContactChange {
  final Change type;
  final model.Contact contact;

  ReceptionContactChange.create(this.contact) : type = Change.created;
  ReceptionContactChange.delete(this.contact) : type = Change.deleted;
  ReceptionContactChange.update(this.contact) : type = Change.updated;
}

class ReceptionContact {
  final controller.Reception _receptionController;
  final controller.Contact _contactController;
  final controller.Endpoint _endpointController;
  final controller.Calendar _calendarController;
  final controller.DistributionList _dlistController;

  ///TODO: Add additional validation checks
  bool get inputHasErrors =>
      _endpointsView.validationError ||
      _distributionsListView.validationError ||
      _phoneNumberView.validationError;

  final UListElement _endPointChangesList = new UListElement();
  final UListElement _dlistChangesList = new UListElement();

  final HeadingElement _header = new HeadingElement.h4()
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
  ContactCalendarComponent _calendarComponent;

  /**
   *
   */
  ReceptionContact(
      this._receptionController,
      this._contactController,
      this._endpointController,
      this._calendarController,
      this._dlistController) {
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
                ..text = 'Afdelinger'
                ..htmlFor = _departmentsInput.id,
              _departmentsInput
            ],
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
                ..text = 'Telefonnumre'
                ..htmlFor = _phoneNumberView.element.id,
              _phoneNumberView.element
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Info'
                ..htmlFor = _infoInput.id,
              _infoInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Beskedadresser'
                ..htmlFor = _endpointsView.element.id,
              _endPointChangesList,
              _endpointsView.element
            ],
        ],

      /// Right column.
      new DivElement()
        ..classes.add('col-1-2')
        ..children = [
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
                ..text = 'Relationer'
                ..htmlFor = _relationsInput.id,
              _relationsInput
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
                ..text = 'Titler'
                ..htmlFor = _titlesInput.id,
              _titlesInput
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
                ..text = 'Distributionsliste'
                ..htmlFor = _distributionsListView.element.id,
              _dlistChangesList,
              _distributionsListView.element
            ],
        ],
      new DivElement()
        ..text = '.'
        ..style.color = 'white'
    ];

    _observers();
  }

  /**
   *
   */
  void _observers() {
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
          notify.error('Beskedadresser ikke opdateret: $e');
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
          notify.error('Distributionsliste ikke opdateret: $e');
        }

        notify.info('Receptions-kontakten blev opdateret.');
      } catch (error) {
        notify.error('Receptions-kontakten blev ikke opdateret.');
      }

      /// Reload the contact.
      contact = await _contactController.getByReception(
          contact.ID, contact.receptionID);
    });

    _deleteButton.onClick.listen((_) async {
      try {
        await _contactController.removeFromReception(
            contact.ID, contact.receptionID);
        notify.info(
            'Receptions-kontakten blev fjernet fra receptionen ${_header.text}');
        element.remove();
      } catch (error) {
        notify.error('Receptions-kontakten blev ikke slettet.');
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
      try {
        _endPointChangesList.children = []
          ..addAll(_endpointsView.endpointChanges.map(_endpointChangeNode));
      } on FormatException {
        _endPointChangesList.text = 'Valideringsfejl.';
      }

      _saveButton.disabled = inputHasErrors;
      _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;
    };

    _distributionsListView.onChange = () {
      try {
        _dlistChangesList.children = []
          ..addAll(_distributionsListView.distributionListChanges
              .map(_distributionListChangeNode));
      } on FormatException {
        _endPointChangesList.text = 'Valideringsfejl.';
      }
      _saveButton.disabled = inputHasErrors;
      _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;
    };

    _phoneNumberView.onChange = () {
      _saveButton.disabled = inputHasErrors;
      _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;
    };
  }

  /**
   *
   */
  LIElement _distributionListChangeNode(DistributionListChange change) =>
      new LIElement()..text = '${changeLabel[change.type]} ${change.entry}';

  /**
   *
   */
  LIElement _endpointChangeNode(EndpointChange change) =>
      new LIElement()..text = '${changeLabel[change.type]} ${change.endpoint}';

  /**
   *
   */
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
    ..tags = _valuesFromListTextArea(_tagsInput)
    ..titles = _valuesFromListTextArea(_titlesInput)
    ..workhours = _valuesFromListTextArea(_workHoursInput)
    ..phones = _phoneNumberView.phoneNumbers.toList();

  /**
   *
   */
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

  /**
   *
   */
  UListElement _createPhoneNumbersList(
      Element container, List<model.PhoneNumber> phonenumbers,
      {Function onChange}) {
    ParagraphElement label = new ParagraphElement();
    UListElement ul = new UListElement()..classes.add('content-list');

    label.text = 'Telefonnumre';

    List<LIElement> children = new List<LIElement>();
    if (phonenumbers != null) {
      for (model.PhoneNumber number in phonenumbers) {
        LIElement li = simpleListElement(number.endpoint, onChange: onChange);

        SelectElement kindpicker = new SelectElement()
          ..children.addAll(phonenumberTypes.map((String kind) =>
              new OptionElement(
                  data: kind, value: kind, selected: kind == number.type)))
          ..onChange.listen((_) => onChange());

        SpanElement descriptionContent = new SpanElement()
          ..text = number.description
          ..classes.add('phonenumberdescription');
        InputElement descriptionEditBox = new InputElement(type: 'text');
        editableSpan(descriptionContent, descriptionEditBox, onChange);

        SpanElement billingTypeContent = new SpanElement()
          ..text = number.billing_type
          ..classes.add('phonenumberbillingtype');
        InputElement billingTypeEditBox = new InputElement(type: 'text');
        editableSpan(billingTypeContent, billingTypeEditBox, onChange);

        li.children.addAll([
          kindpicker,
          descriptionContent,
          descriptionEditBox,
          billingTypeContent,
          billingTypeEditBox
        ]);
        children.add(li);
      }
    }

    InputElement inputNewItem = new InputElement();
    inputNewItem
      ..classes.add(addNewLiClass)
      ..placeholder = 'Tilføj ny...'
      ..onKeyPress.listen((KeyboardEvent event) {
        KeyEvent key = new KeyEvent.wrap(event);
        if (key.keyCode == Keys.ENTER) {
          String item = inputNewItem.value;
          inputNewItem.value = '';

          LIElement li = simpleListElement(item);
          //A bit of a hack to get a unique id.
          li.value = item.hashCode;
          SelectElement kindpicker = new SelectElement()
            ..children.addAll(phonenumberTypes.map(
                (String kind) => new OptionElement(data: kind, value: kind)))
            ..onChange.listen((_) => onChange());

          SpanElement descriptionContent = new SpanElement()
            ..text = 'kontor'
            ..classes.add('phonenumberdescription');
          InputElement descriptionEditBox = new InputElement(type: 'text')
            ..placeholder = 'beskrivelse';
          editableSpan(descriptionContent, descriptionEditBox, onChange);

          SpanElement billingTypeContent = new SpanElement()
            ..text = 'fastnet'
            ..classes.add('phonenumberbillingtype');
          InputElement billingTypeEditBox = new InputElement(type: 'text')
            ..placeholder = 'taksttype';
          editableSpan(billingTypeContent, billingTypeEditBox, onChange);

          li.children.addAll([
            kindpicker,
            descriptionContent,
            descriptionEditBox,
            billingTypeContent,
            billingTypeEditBox
          ]);

          int index = ul.children.length - 1;
          ul.children.insert(index, li);

          if (onChange != null) {
            onChange();
          }
        } else if (key.keyCode == Keys.ESCAPE) {
          inputNewItem.value = '';
        }
      });

    children.add(new LIElement()..children.add(inputNewItem));

    ul.children
      ..clear()
      ..addAll(children);

    container.children.addAll([label, ul]);

    return ul;
  }

  /**
   *
   */
  List<model.PhoneNumber> getPhoneNumbersFromDOM(UListElement element) {
    List<model.PhoneNumber> phonenumbers = new List<model.PhoneNumber>();

    for (LIElement li in element.children) {
      if (!li.classes.contains(addNewLiClass)) {
        SpanElement content = li.children.firstWhere(
            (elem) =>
                elem is SpanElement &&
                elem.classes.contains('contactgenericcontent'),
            orElse: () => null);
        SelectElement kindpicker = li.children
            .firstWhere((elem) => elem is SelectElement, orElse: () => null);
        SpanElement description = li.children.firstWhere(
            (elem) =>
                elem is SpanElement &&
                elem.classes.contains('phonenumberdescription'),
            orElse: () => null);
        SpanElement billingType = li.children.firstWhere(
            (elem) =>
                elem is SpanElement &&
                elem.classes.contains('phonenumberbillingtype'),
            orElse: () => null);

        if (content != null && kindpicker != null) {
          phonenumbers.add(new model.PhoneNumber.empty()
            ..type = kindpicker.options[kindpicker.selectedIndex].value
            ..endpoint = content.text
            ..description = description.text
            ..billing_type = billingType.text);
        }
      }
    }
    return phonenumbers;
  }
}

InputElement createCheckBox(Element container, String labelText, bool data,
    {Function onChange}) {
  ParagraphElement label = new ParagraphElement();
  CheckboxInputElement inputCheckbox = new CheckboxInputElement();

  label.text = labelText;
  inputCheckbox.checked = data;

  if (onChange != null) {
    inputCheckbox.onChange.listen((_) {
      onChange();
    });
  }

  container.children.addAll([label, inputCheckbox]);
  return inputCheckbox;
}

TableCellElement createTableCellInsertInRow(TableRowElement row) {
  TableCellElement td = new TableCellElement();
  row.children.add(td);
  return td;
}

TableRowElement createTableRowInsertInTable(TableSectionElement table) {
  TableRowElement row = new TableRowElement();
  table.children.add(row);
  return row;
}

UListElement createListBox(
    Element container, String labelText, List<String> dataList,
    {Function onChange}) {
  ParagraphElement label = new ParagraphElement();
  UListElement ul = new UListElement()..classes.add('content-list');

  label.text = labelText;
  fillList(ul, dataList, onChange: onChange);

  container.children.addAll([label, ul]);

  return ul;
}
