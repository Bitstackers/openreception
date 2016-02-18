part of management_tool.view;

class MessageFilter {
  final DateFormat RFC3339 = new DateFormat('yyyy-MM-dd HH:mm');
  final Logger _log = new Logger('$_libraryName.Calendar');
  final controller.Contact _contactController;
  final controller.Reception _receptionController;
  final controller.User _userController;

  final DivElement element = new DivElement()..classes.add('full-width');

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

  int get _uid => int.parse(_userSelector.selectedOptions.first.value);

  int get _cid {
    if (_contactSelector.selectedOptions.length < 1 ||
        _contactSelector.disabled) {
      return model.Contact.noID;
    }

    return int.parse(_contactSelector.selectedOptions.first.value);
  }

  int get _rid => int.parse(_receptionSelector.selectedOptions.first.value);

  MessageFilter(this._contactController, this._receptionController,
      this._userController) {
    element.children = [
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
    _userSelector.onInput.listen((_) {
      onChange != null ? onChange() : '';
    });

    _receptionSelector.onInput.listen((_) {
      _reloadContactSelector();
      onChange != null ? onChange() : '';

      _contactSelector.disabled = _rid == model.Contact.noID;
    });

    _contactSelector.onInput.listen((_) {
      onChange != null ? onChange() : '';
    });
  }

  /**
   *
   */
  Future _reloadContactSelector() async {
    Iterable<model.Contact> contacts =
        _rid != model.Reception.noID ? await _contactController.list(_rid) : [];

    OptionElement contactToOption(model.Contact contact) => new OptionElement()
      ..label = contact.fullName
      ..value = contact.ID.toString();

    _contactSelector.children = [
      new OptionElement()
        ..text = ''
        ..value = model.Contact.noID.toString()
    ]..addAll(contacts.map(contactToOption));
  }

  /**
   *
   */
  Future _reloadUserSelector() async {
    Iterable<model.User> users = await _userController.list();

    OptionElement userToOption(model.User user) => new OptionElement()
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
    Iterable<model.Reception> rcps = await _receptionController.list();

    OptionElement receptionToOption(model.Reception r) => new OptionElement()
      ..label = r.name
      ..value = r.ID.toString();

    _receptionSelector.children = [
      new OptionElement()
        ..text = ''
        ..value = '0'
    ]..addAll(rcps.map(receptionToOption));
  }

  void set filter(model.MessageFilter filter) {}

  model.MessageFilter get filter => new model.MessageFilter.empty()
    ..contactID = _cid
    ..userID = _uid
    ..receptionID = _rid;
}
