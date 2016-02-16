part of management_tool.view;

class ReceptionChange {
  final Change type;
  final model.Reception reception;

  ReceptionChange.create(this.reception) : type = Change.created;
  ReceptionChange.delete(this.reception) : type = Change.deleted;
  ReceptionChange.update(this.reception) : type = Change.updated;
}

/**
 *
 */
class Reception {
  final DivElement element = new DivElement()
    ..classes = ['reception', 'page']
    ..hidden = true;

  final Logger _log = new Logger('$_libraryName.Reception');
  final controller.Reception _recController;
  final controller.Organization _orgController;

  bool get inputHasErrors => _phoneNumberView._validationError;

  Stream<ReceptionChange> get changes => _changeBus.stream;
  final Bus<ReceptionChange> _changeBus = new Bus<ReceptionChange>();

  final LabelElement _oidLabel = new LabelElement()..text = 'rid:??';
  final HiddenInputElement _idInput = new HiddenInputElement()
    ..value = model.Reception.noID.toString();
  final ButtonElement _saveButton = new ButtonElement()
    ..classes.add('save')
    ..text = 'Gem';
  final ButtonElement _deleteButton = new ButtonElement()
    ..text = 'Slet'
    ..classes.add('delete');
  final ButtonElement _deployDialplanButton = new ButtonElement()
    ..text = 'Udrul'
    ..disabled = true
    ..classes.add('deploy');

  final HeadingElement _heading = new HeadingElement.h2();
  final DivElement _lastChecked = new DivElement();

  final InputElement _nameInput = new InputElement()
    ..classes.add('wide')
    ..value = '';

  final InputElement _extraDataInput = new InputElement()
    ..classes.add('wide')
    ..value = '';
  final InputElement _greetingInput = new InputElement()
    ..classes.add('wide')
    ..value = '';

  final InputElement _dialplanInput = new InputElement()
    ..classes.add('semi-wide')
    ..value = 'empty';

  final InputElement _shortGreetingInput = new InputElement()
    ..classes.add('wide')
    ..value = '';

  final InputElement _otherDataInput = new InputElement()
    ..classes.add('wide')
    ..value = '';

  final CheckboxInputElement _activeInput = new CheckboxInputElement()
    ..checked = true;

  final TextAreaElement _productInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';

  final TextAreaElement _addressesInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _instructionsInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';

  final TextAreaElement _alternateNamesInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';

  final TextAreaElement _bankingInformationInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';

  final TextAreaElement _salesMarketingHandlingInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';

  final TextAreaElement _emailAddressesInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';

  final TextAreaElement _openingHoursInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _vatNumbersInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _websitesInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';
  final TextAreaElement _customerTypesInput = new TextAreaElement()
    ..classes.add('wide')
    ..value = '';

  final TextAreaElement _miniWikiInput = new TextAreaElement()
    ..classes.addAll(['full-width'])
    ..style.height = '20em'
    ..value = '';

  Phonenumbers _phoneNumberView;

  final DivElement _organizationSelector = new DivElement();

  SearchComponent<model.Organization> _search;
  int _organizationId = model.Organization.noID;

  void set reception(model.Reception r) {
    _organizationId = r.organizationId;
    _heading.text = r.name;
    _idInput.value = r.ID.toString();

    _nameInput.value = r.fullName;
    _oidLabel.text = 'rid:${r.ID}';
    _greetingInput.value = r.greeting;
    _shortGreetingInput.value = r.shortGreeting;
    _dialplanInput.value = r.dialplan != null ? r.dialplan : 'empty';

    _lastChecked.text = r.lastChecked.isAtSameMomentAs(util.never)
        ? 'Sidst checket: Aldrig'
        : 'Sidst checket: ${r.lastChecked}';

    _activeInput.checked = r.enabled;
    _extraDataInput.value = r.extraData != null ? r.extraData.toString() : '';

    _phoneNumberView.phoneNumbers = r.telephoneNumbers;

    _addressesInput.value = r.addresses != null ? r.addresses.join('\n') : '';

    _alternateNamesInput.value =
        r.alternateNames != null ? r.alternateNames.join('\n') : '';
    _bankingInformationInput.value =
        r.bankingInformation != null ? r.bankingInformation.join('\n') : '';
    _salesMarketingHandlingInput.value = r.salesMarketingHandling != null
        ? r.salesMarketingHandling.join('\n')
        : '';
    _emailAddressesInput.value =
        r.emailAddresses != null ? r.emailAddresses.join('\n') : '';

    _openingHoursInput.value =
        r.openingHours != null ? r.openingHours.join('\n') : '';

    _vatNumbersInput.value =
        r.vatNumbers != null ? r.vatNumbers.join('\n') : '';

    _websitesInput.value = r.websites != null ? r.websites.join('\n') : '';

    _customerTypesInput.value =
        r.customerTypes != null ? r.customerTypes.join('\n') : '';

    _instructionsInput.value =
        r.handlingInstructions != null ? r.handlingInstructions.join('\n') : '';

    _shortGreetingInput.value = r.shortGreeting;

    _miniWikiInput.value = r.miniWiki;

    _otherDataInput.value = r.otherData;
    _productInput.value = r.product;

    if (reception.ID != model.Reception.noID) {
      _heading.text =
          'Retter reception "${reception.name}" (rid:${reception.ID})';
      _saveButton.disabled = true;
    } else {
      _heading.text = 'Opretter ny reception';
      _saveButton.disabled = false;
    }

    _deleteButton
      ..text = 'Slet'
      ..disabled = !_saveButton.disabled;

    _orgController.list().then((Iterable<model.Organization> orgs) {
      int compareTo(model.Organization org1, model.Organization org2) =>
          org1.fullName.compareTo(org2.fullName);

      List list = orgs.toList()..sort(compareTo);
      _search.updateSourceList(list);

      _search.selectElement(null, (model.Organization listItem, _) {
        return listItem.id == r.organizationId;
      });

      element.hidden = false;
    });
  }

  /**
   *
   */
  model.Reception get reception => new model.Reception.empty()
    ..ID = int.parse(_idInput.value)
    ..fullName = _nameInput.value
    ..addresses = _valuesFromListTextArea(_addressesInput)
    ..alternateNames = _valuesFromListTextArea(_alternateNamesInput)
    ..bankingInformation = _valuesFromListTextArea(_bankingInformationInput)
    ..customerTypes = _valuesFromListTextArea(_customerTypesInput)
    ..dialplan = _dialplanInput.value
    ..emailAddresses = _valuesFromListTextArea(_emailAddressesInput)
    ..enabled = _activeInput.checked
    ..extraData = _validUri(_extraDataInput.value)
    ..greeting = _greetingInput.value
    ..shortGreeting = _shortGreetingInput.value
    ..handlingInstructions = _valuesFromListTextArea(_instructionsInput)
    ..miniWiki = _miniWikiInput.value
    ..openingHours = _valuesFromListTextArea(_openingHoursInput)
    ..organizationId = _organizationId
    ..otherData = _otherDataInput.value
    ..product = _productInput.value
    ..salesMarketingHandling =
        _valuesFromListTextArea(_salesMarketingHandlingInput)
    ..telephoneNumbers = _phoneNumberView.phoneNumbers.toList()
    ..vatNumbers = _valuesFromListTextArea(_vatNumbersInput)
    ..websites = _valuesFromListTextArea(_websitesInput);

  /**
   *
   */
  Reception(this._recController, this._orgController) {
    _phoneNumberView = new Phonenumbers();

    _search = new SearchComponent<model.Organization>(
        _organizationSelector, 'reception-organization-searchbox')
      ..selectedElementChanged = (model.Organization organization) {
        _organizationId = organization.id;
      }
      ..listElementToString =
          (model.Organization organization, String searchterm) {
        return '${organization.fullName}';
      }
      ..searchFilter = (model.Organization organization, String searchTerm) {
        return organization.fullName
            .toLowerCase()
            .contains(searchTerm.toLowerCase());
      }
      ..searchPlaceholder = 'Søg...';

    element.children = [
      new DivElement()
        ..style.width = '100%'
        ..children = [
          _saveButton,
          _deleteButton,
          _heading,
          _lastChecked,
          new SpanElement()..text = 'Organization: ',
          _organizationSelector,
          new SpanElement()..text = 'Aktiv: ',
          _activeInput,
        ],
      _idInput,
      new DivElement()
        ..classes.add('col-1-2')
        ..children = [
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Navn'
                ..htmlFor = _nameInput.id,
              _nameInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Velkomsthilsen'
                ..htmlFor = _greetingInput.id,
              _greetingInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Extra data URI'
                ..htmlFor = _extraDataInput.id,
              _extraDataInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Kommandoer'
                ..htmlFor = _instructionsInput.id,
              _instructionsInput
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
                ..text = 'Bankinformation'
                ..htmlFor = _bankingInformationInput.id,
              _bankingInformationInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Sælgere'
                ..htmlFor = _salesMarketingHandlingInput.id,
              _salesMarketingHandlingInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'CVR-numre'
                ..htmlFor = _vatNumbersInput.id,
              _vatNumbersInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Websites'
                ..htmlFor = _websitesInput.id,
              _websitesInput
            ],
        ],
      new DivElement()
        ..classes.add('col-1-2')
        ..children = [
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Kaldplan'
                ..htmlFor = _dialplanInput.id,
              _dialplanInput,
              _deployDialplanButton
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Kort velkomsthilsen'
                ..htmlFor = _shortGreetingInput.id,
              _shortGreetingInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Adresser'
                ..htmlFor = _addressesInput.id,
              _addressesInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Åbningstider'
                ..htmlFor = _openingHoursInput.id,
              _openingHoursInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Alternative navne'
                ..htmlFor = _alternateNamesInput.id,
              _alternateNamesInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Email adresseser'
                ..htmlFor = _emailAddressesInput.id,
              _emailAddressesInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Kundetyper'
                ..htmlFor = _customerTypesInput.id,
              _customerTypesInput
            ],
          new DivElement()
            ..children = [
              new LabelElement()
                ..text = 'Produkter'
                ..htmlFor = _productInput.id,
              _productInput
            ],
        ],
      new DivElement()
        ..style.clear = 'both'
        ..children = [
          new LabelElement()
            ..text = 'MiniWiki'
            ..htmlFor = _miniWikiInput.id,
          _miniWikiInput
        ],
    ];

    _observers();
  }

  /**
   *
   */
  void _observers() {
    Iterable<Element> inputs = element.querySelectorAll('input,textarea');

    inputs.forEach((Element ine) {
      ine.onInput.listen((_) {
        _saveButton.disabled = false;
        _deleteButton.disabled = !_saveButton.disabled;
      });
    });

    _activeInput.onChange.listen((_) {
      _saveButton.disabled = false;
      _deleteButton.disabled = !_saveButton.disabled;
    });

    _deleteButton.onClick.listen((_) async {
      if (_deleteButton.text.toLowerCase() == 'slet') {
        _deleteButton.text = 'Bekræft sletning af rid:${reception.ID}?';
        return;
      }

      try {
        await _recController.remove(reception.ID);
        _changeBus.fire(new ReceptionChange.delete(reception));
        element.hidden = true;
        notify.info('Receptionen blev slettet.');
      } catch (error) {
        notify.error('Der skete en fejl, så recpetionen blev ikke slettet.');
        _log.severe('Tried to remove a reception, but got: $error');
        element.hidden = false;
      }

      _phoneNumberView.onChange = () {
        _saveButton.disabled = inputHasErrors;
        _deleteButton.disabled = inputHasErrors || !_saveButton.disabled;
      };
    });

    _saveButton.onClick.listen((_) async {
      element.hidden = true;
      if (reception.ID == model.Reception.noID) {
        try {
          model.Reception newRec = await _recController.create(reception);
          _changeBus.fire(new ReceptionChange.create(newRec));
          notify.info('Receptionen blev oprettet.');
        } catch (error) {
          notify.error('Der skete en fejl, så receptionen blev ikke oprettet.');
          _log.severe('Tried to create a new reception, but got: $error');
          element.hidden = false;
        }
      } else {
        try {
          await _recController.update(reception);
          _changeBus.fire(new ReceptionChange.update(reception));
          notify.info('Ændringerne blev gemt.');
        } catch (error) {
          notify.error(
              'Der skete en fejl i forbindelse med forsøget på at gemme ændringerne til receptionen.');
          _log.severe('Tried to update a reception, but got: $error');
          element.hidden = false;
        }
      }
    });
  }
}
