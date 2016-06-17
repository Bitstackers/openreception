part of management_tool.view;

enum Change { added, created, updated, deleted }

const Map<Change, String> changeLabel = const {
  Change.created: 'Opretter',
  Change.updated: 'Opdater',
  Change.deleted: 'Sletter'
};

class UserChange {
  final Change type;
  final model.User user;

  UserChange.create(this.user) : type = Change.created;
  UserChange.delete(this.user) : type = Change.deleted;
  UserChange.update(this.user) : type = Change.updated;
}

class User {
  final DivElement element = new DivElement()
    ..id = 'user-content'
    ..hidden = true;

  final Logger _log = new Logger('$_libraryName.User');

  Stream<UserChange> get changes => _changeBus.stream;
  final Bus<UserChange> _changeBus = new Bus<UserChange>();

  final controller.User _userController;
  final controller.PeerAccount _peerAccountController;

  UserGroups _groupsView;
  UserIdentities _identitiesView;
  PeerAccount _peerAccountView;
  ObjectHistory _historyView;
  final AnchorElement _historyToggle = new AnchorElement()
    ..href = '#history'
    ..text = 'Vis historik';

  final LabelElement _uidLabel = new LabelElement()..text = 'uid:??';
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
    _historyView = new ObjectHistory();
    _historyView.element.hidden = true;
    _historyToggle..text = 'Vis historik';

    _groupsView = new UserGroups(_userController);
    _identitiesView = new UserIdentities(_userController);
    _peerAccountView = new PeerAccount(_peerAccountController, this);

    element.children = [
      _saveButton,
      _deleteButton,
      _uidLabel..htmlFor = _userIdInput.id,
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
      _historyToggle,
      _historyView.element,
      new DivElement()
        ..children = [
          new HeadingElement.h5()..text = 'SIP konto',
          _peerAccountView.element
        ],
    ];
    _observers();
  }

  /**
   *
   */
  void _observers() {
    Iterable<InputElement> inputs =
        element.querySelectorAll('input') as Iterable<InputElement>;

    _historyToggle.onClick.listen((_) async {
      await _userController.changes(user.id).then((c) {
        _historyView.commits = c;
      });

      _historyView.element.hidden = !_historyView.element.hidden;

      _historyToggle.text =
          _historyView.element.hidden ? 'Vis historik' : 'Skjul historik';
    });

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
    /// Reset labels.
    _deleteButton.text = 'Slet';
    _historyView.element.hidden = true;
    _historyToggle..text = 'Vis historik';

    _deleteButton.disabled = u.id == model.User.noId;
    _saveButton.disabled = u.id != model.User.noId;
    _deleteButton.disabled = !_saveButton.disabled;
    _userIdInput.value = u.id.toString();
    _userNameInput.value = u.name;
    _userSendFromInput.value = u.address;

    _groupsView.groups = u.groups;
    _identitiesView.identities = u.identities;

    _peerAccountController.get(user.extension).then((model.PeerAccount pa) {
      _peerAccountView.account = pa;
    }).catchError((_) {
      _peerAccountView.account = new model.PeerAccount('', '', '');
    }).whenComplete(show);
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
      _changeBus.fire(new UserChange.delete(user));
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

    model.User u;

    try {
      if (userId != model.User.noId) {
        u = await _userController
            .update(user)
            .then((ref) => _userController.get(ref.id));
        _changeBus.fire(new UserChange.update(u));
      } else {
        u = await _userController
            .create(user)
            .then((ref) => _userController.get(ref.id));
        _changeBus.fire(new UserChange.create(u));
      }

      notify.success('Brugeren blev opdateret', user.name);
    } catch (error) {
      notify.error('Kunne ikke opdatere bruger', 'Fejl: $error');
      _log.severe('Save user failed with: ${error}');
    }
  }
}
