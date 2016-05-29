part of management_tool.view;

class MessageFilter {
  final Logger _log = new Logger('$_libraryName.Calendar');
  final controller.Contact _contactController;
  final controller.Reception _receptionController;
  final controller.User _userController;

  final DivElement element = new DivElement()..classes.add('full-width');
  final InputElement _lastDateInput = new InputElement(type: 'date')
    ..valueAsDate = new DateTime.now();
  final InputElement _numdaysInput = new InputElement(type: 'number')
    ..min = '1'
    ..max = '31'
    ..valueAsNumber = 1;

  DateTime get lastDate => _lastDateInput.valueAsDate;
  void set lastDate(DateTime date) {
    _lastDateInput.valueAsDate = date;
  }

  int get numDays => _numdaysInput.valueAsNumber;

  Function onChange;

  final SelectElement _userSelector = new SelectElement()
    ..classes.add('full-width');

  final SelectElement _receptionSelector = new SelectElement()
    ..classes.add('full-width');

  final SelectElement _contactSelector = new SelectElement()
    ..classes.add('full-width')
    ..children = [
      new OptionElement()
        ..text = ''
        ..value = '0'
    ]
    ..disabled = true;

  final RadioButtonInputElement _showSavedInput = new RadioButtonInputElement()
    ..text = 'Vis gemte'
    ..name = 'saved-toggle'
    ..checked = true
    ..value = 'saved';

  final RadioButtonInputElement _showByDateInput = new RadioButtonInputElement()
    ..text = 'Vis fra dato'
    ..name = 'saved-toggle'
    ..value = 'archive';

  RadioButtonInputElement get _selectedRadioButton =>
      [_showSavedInput, _showByDateInput].firstWhere((e) => e.checked);

  bool get showSaved => _selectedRadioButton.value == 'saved';

  int get _uid => _userSelector.children.isEmpty
      ? model.User.noId
      : int.parse(_userSelector.selectedOptions.first.value);

  int get _cid {
    if (_contactSelector.selectedOptions.length < 1 ||
        _contactSelector.disabled) {
      return model.BaseContact.noId;
    }

    return int.parse(_contactSelector.selectedOptions.first.value);
  }

  int get _rid => _receptionSelector.children.isEmpty
      ? model.Reception.noId
      : int.parse(_receptionSelector.selectedOptions.first.value);

  MessageFilter(this._contactController, this._receptionController,
      this._userController) {
    element.children = [
      new DivElement()
        ..children = [
          new DivElement()
            ..children = [
              new LabelElement()..text = 'Vis gemte',
              _showSavedInput,
            ],
          new DivElement()
            ..children = [
              new LabelElement()..text = 'Vis fra dato',
              _showByDateInput,
              _lastDateInput,
              new LabelElement()..text = 'Antal dage tilbage',
              _numdaysInput
            ]
        ],
      new DivElement()
        ..children = [
          new HeadingElement.h3()..text = 'Taget af bruger',
          _userSelector
        ],
      new DivElement()
        ..children = [
          new HeadingElement.h3()..text = 'Reception',
          _receptionSelector
        ],
      new DivElement()
        ..children = [
          new HeadingElement.h3()..text = 'Kontaktperson',
          _contactSelector
        ]
    ];

    _reloadUserSelector();
    _reloadReceptionSelector();

    _observers();
  }

  /**
   *
   */
  void _observers() {
    _showSavedInput.onChange.listen((_) {
      onChange != null ? onChange() : '';
    });
    _showByDateInput.onChange.listen((_) {
      onChange != null ? onChange() : '';
    });

    _userSelector.onInput.listen((_) {
      onChange != null ? onChange() : '';
    });

    _numdaysInput.onInput.listen((_) {
      if (!showSaved) {
        onChange != null ? onChange() : '';
      }
    });

    _lastDateInput.onInput.listen((_) {
      if (!showSaved) {
        onChange != null ? onChange() : '';
      }
    });

    _receptionSelector.onInput.listen((_) {
      _reloadContactSelector();
      onChange != null ? onChange() : '';

      _contactSelector.disabled = _rid == model.BaseContact.noId;
    });

    _contactSelector.onInput.listen((_) {
      onChange != null ? onChange() : '';
    });
  }

  /**
   *
   */
  Future _reloadContactSelector() async {
    List<model.BaseContact> contacts = [];

    if (_rid != model.Reception.noId) {
      contacts = (await _contactController.list()).toList(growable: false)
        ..sort(compareContacts);
    }

    OptionElement contactToOption(model.BaseContact cRef) => new OptionElement()
      ..label = cRef.name
      ..value = cRef.id.toString();

    _contactSelector.children = [
      new OptionElement()
        ..text = ''
        ..value = model.BaseContact.noId.toString()
    ]..addAll(contacts.map(contactToOption));
  }

  /**
   *
   */
  Future _reloadUserSelector() async {
    List<model.UserReference> users = (await _userController.list())
        .toList(growable: false)..sort(compareUserRefs);

    OptionElement userToOption(model.UserReference user) => new OptionElement()
      ..label = user.name
      ..value = user.id.toString();

    _userSelector.children = [
      new OptionElement()
        ..text = ''
        ..value = '0'
    ]..addAll(users.map(userToOption));
  }

  /**
   *
   */

  Future _reloadReceptionSelector() async {
    List<model.ReceptionReference> rcps = (await _receptionController.list())
        .toList(growable: false)..sort(compareRecRefs);

    OptionElement receptionToOption(model.ReceptionReference r) =>
        new OptionElement()
          ..label = r.name
          ..value = r.id.toString();

    _receptionSelector.children = [
      new OptionElement()
        ..text = ''
        ..value = '0'
    ]..addAll(rcps.map(receptionToOption));
  }

  model.MessageFilter get filter => new model.MessageFilter.empty()
    ..contactId = _cid
    ..userId = _uid
    ..receptionId = _rid;
}
