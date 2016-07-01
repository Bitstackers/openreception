part of management_tool.view;

class User {
  final DivElement element = new DivElement()
    ..id = 'user-content'
    ..hidden = true;

  final Logger _log = new Logger('$_libraryName.User');

  final controller.User _userController;
  final controller.PeerAccount _peerAccountController;
  Changelog _changelog;

  UserGroups _groupsView;
  UserIdentities _identitiesView;
  PeerAccount _peerAccountView;

  final HeadingElement _heading = new HeadingElement.h2()..text = 'Henter...';
  final HiddenInputElement _userIdInput = new HiddenInputElement()
    ..id = 'user-id'
    ..text = model.User.noId.toString();
  final InputElement _userNameInput = new InputElement()..id = 'user-name';

  final InputElement _userSendFromInput = new InputElement()
    ..id = 'user-sendfrom';

  String get userExtension => _peerAccountView.account.username;

  final ButtonElement _saveButton = new ButtonElement()
    ..text = 'Gem'
    ..classes.add('save')
    ..disabled = true;

  final ButtonElement _deleteButton = new ButtonElement()
    ..text = 'Slet'
    ..classes.add('delete');

  int get userId => int.parse(_userIdInput.value);

  void hide() {
    element.hidden = true;
  }

  void show() {
    element.hidden = false;
  }

  /**
   *
   */
  User(this._userController,
      controller.PeerAccount this._peerAccountController) {
    _changelog = new Changelog();

    _groupsView = new UserGroups(_userController);
    _identitiesView = new UserIdentities(_userController);
    _peerAccountView = new PeerAccount(_peerAccountController, this);

    element.children = [
      _saveButton,
      _deleteButton,
      _heading,
      _userIdInput,
      new DivElement()
        ..children = [
          new LabelElement()
            ..text = 'Navn'
            ..htmlFor = _userNameInput.id,
          _userNameInput
        ],
      new DivElement()
        ..children = [
          new LabelElement()
            ..text = 'Send-fra adresse'
            ..htmlFor = _userSendFromInput.id,
          _userSendFromInput
        ],
      new LabelElement()..text = 'Grupper',
      _groupsView.element,
      new LabelElement()..text = 'Identitieter',
      _identitiesView.element,
      new DivElement()
        ..children = [
          new HeadingElement.h5()..text = 'SIP konto',
          _peerAccountView.element
        ],
      _changelog.element
    ];
    _observers();
  }

  /**
   *
   */
  void _observers() {
    Iterable<InputElement> inputs = element.querySelectorAll('input');

    _groupsView.onChange = () {
      _saveButton.disabled = false;
      _deleteButton.disabled = !_saveButton.disabled;
    };

    _identitiesView.onChange = () {
      _saveButton.disabled = false;
      _deleteButton.disabled = !_saveButton.disabled;
    };

    inputs.forEach((InputElement ine) {
      ine.onInput.listen((_) {
        _saveButton.disabled = false;
        _deleteButton.disabled = !_saveButton.disabled;
      });
    });

    _saveButton.onClick.listen((_) async {
      await _updateUser();
    });

    _deleteButton.onClick.listen((_) {
      _deleteUser();
    });
  }

  ///
  void set user(model.User u) {
    clear();

    /// Reset labels.
    _deleteButton.text = 'Slet';

    _deleteButton.disabled = u.id == model.User.noId;
    _saveButton.disabled = u.id != model.User.noId;
    _deleteButton.disabled = !_saveButton.disabled;
    _userIdInput.value = u.id.toString();
    _userNameInput.value = u.name;
    _userSendFromInput.value = u.address;

    _groupsView.groups = u.groups;
    _identitiesView.identities = u.identities;

    if (u.id != model.User.noId) {
      _heading.text = 'Retter bruger ${u.name} (uid:${u.id})';
      Future.wait([
        _loadChangeLog(u.id),
        _peerAccountView.loadAccount(u.extension)
      ]).whenComplete(show);
    } else {
      _heading.text = 'Opret ny bruger';
      show();
    }
  }

  /**
   *
   */
  Future _loadChangeLog(int uid) async {
    _changelog.content = await _userController.changelog(uid);
  }

  /**
   *
   */
  model.User get user => new model.User.empty()
    ..id = userId
    ..name = _userNameInput.value
    ..address = _userSendFromInput.value
    ..groups = _groupsView.groups.toSet()
    ..identities = _identitiesView.identities.toSet()
    ..extension = userExtension;

  /**
   *
   */
  Future _deleteUser() async {
    _log.finest('Deleting user uid$userId');
    final String confirmationText = 'Bekræft sletning af uid: ${user.id}?';

    if (_deleteButton.text != confirmationText) {
      _deleteButton.text = confirmationText;
      return;
    }

    try {
      _deleteButton.disabled = true;

      await _userController.remove(userId);
      notify.success('Bruger slettet', user.name);

      hide();
    } catch (error) {
      notify.error('Bruger ikke slettet', 'Fejl: $error');
      _log.severe('Delete user failed with: ${error}');
    }

    _deleteButton.text = 'Slet';
  }

  /**
   *
   */
  Future _updateUser() async {
    _saveButton.disabled = true;
    _deleteButton.disabled = true;

    try {
      if (userId != model.User.noId) {
        await _userController
            .update(user)
            .then((ref) => _userController.get(ref.id));
      } else {
        await _userController
            .create(user)
            .then((ref) => _userController.get(ref.id));
      }

      notify.success('Brugeren blev opdateret', user.name);
    } catch (error) {
      notify.error('Kunne ikke opdatere bruger', 'Fejl: $error');
      _log.severe('Save user failed with: ${error}');
    }
  }

  /**
   *
   */
  void set hidden(bool isHidden) {
    element.hidden = isHidden;
  }

  /**
   *
   */
  bool get hidden => element.hidden;

  /**
   * Clear out input fields of the widget.
   */
  void clear() {
    _peerAccountView.clear();
    _changelog.content = '';
    _groupsView.clear();
    _identitiesView.clear();
    _heading.text = '';
    _userIdInput.value = '';
    _userNameInput.value = '';
    _userSendFromInput.value = '';
  }
}
