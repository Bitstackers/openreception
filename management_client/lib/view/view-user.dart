part of management_tool.view;

enum Change { added, created, updated, deleted }

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

  UserGroups _groupsView;
  UserIdentities _identitiesView;

  final LabelElement _uidLabel = new LabelElement()..text = 'uid:??';
  final HiddenInputElement _userIdInput = new HiddenInputElement()
    ..id = 'user-id'
    ..text = model.User.noID.toString();
  final InputElement _userNameInput = new InputElement()..id = 'user-name';

  final InputElement _googleAppCodeInput = new InputElement()
    ..id = 'user-google-appcode';
  final InputElement _googleUsernameInput = new InputElement()
    ..id = 'user-google-username';

  final InputElement _userSendFromInput = new InputElement()
    ..id = 'user-sendfrom';
  final InputElement _userExtensionInput = new InputElement()
    ..id = 'user-extension';

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
  User(this._userController) {
    _groupsView = new UserGroups(_userController);
    _identitiesView = new UserIdentities(_userController);
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
      new DivElement()
        ..children = [
          new LabelElement()
            ..text = 'Google brugernavn'
            ..htmlFor = _googleUsernameInput.id,
          _googleUsernameInput
        ],
      new DivElement()
        ..children = [
          new LabelElement()
            ..text = 'Google Appcode'
            ..htmlFor = _googleAppCodeInput.id,
          _googleAppCodeInput
        ],
      new LabelElement()..text = 'Grupper',
      _groupsView.element,
      new LabelElement()..text = 'Identitieter',
      _identitiesView.element
    ];
    _observers();
  }

  /**
   *
   */
  void _observers() {
    Iterable<InputElement> inputs =
        element.querySelectorAll('input') as Iterable<InputElement>;

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

    _saveButton.onClick.listen((_) {
      _updateUser();
    });

    _deleteButton.onClick.listen((_) {
      _deleteUser();
    });
  }

  ///
  void set user(model.User u) {
    _uidLabel.text = 'uid:${u.id}${!u.enabled ? ' (inaktiv)': ''}';
    _deleteButton.disabled = u.id == model.User.noID;
    _saveButton.disabled = u.id != model.User.noID;
    _deleteButton.disabled = !_saveButton.disabled;
    _userIdInput.value = u.id.toString();
    _userNameInput.value = u.name;
    _userSendFromInput.value = u.address;
    _userExtensionInput.value = u.peer;
    _googleAppCodeInput.value = u.googleAppcode;
    _googleUsernameInput.value = u.googleUsername;

    if (u.id != model.User.noID) {
      _userController.userGroups(u.id).then((Iterable<model.UserGroup> groups) {
        _groupsView.groups = groups;
      });

      _userController
          .identities(u.id)
          .then((Iterable<model.UserIdentity> identities) {
        _identitiesView.identities = identities;
      });
    } else {
      _identitiesView.identities = [];
      _groupsView.groups = [];
    }

    /// Reset labels.
    _deleteButton.text = 'Slet';
    show();
  }

  /**
   *
   */
  model.User get user => new model.User.empty()
    ..id = userId
    ..name = _userNameInput.value
    ..address = _userSendFromInput.value
    ..googleAppcode = _googleAppCodeInput.value
    ..googleUsername = _googleUsernameInput.value
    ..peer = _userExtensionInput.value;

  /**
   *
   */
  Future _deleteUser() async {
    _log.finest('Deleting user uid$userId');
    final String confirmationText = 'Bekræft sletning af uid: ${user.id}?';

    if(_deleteButton.text != confirmationText) {
      _deleteButton.text = confirmationText;
      return;
    }


    try {
      _deleteButton.disabled = true;

      await _userController.remove(userId);
      notify.info('Brugeren er slettet.');
      _changeBus.fire(new UserChange.delete(user));
      hide();
    } catch (error) {
      notify
          .error('Der skete en fejl i forbindelse med sletningen af brugeren');
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
      if (userId != model.User.noID) {
        u = await _userController.update(user);
        _changeBus.fire(new UserChange.update(u));
      } else {
        u = await _userController.create(user);
        _changeBus.fire(new UserChange.create(u));
      }

      /// Store group changes:
      await Future.forEach(_groupsView.changes(), (UserGroupChange ugc) async {
        if (ugc.type == Change.added) {
          await _userController.joinGroup(u.id, ugc.groupId);
        } else if (ugc.type == Change.deleted) {
          await _userController.leaveGroup(u.id, ugc.groupId);
        }
      });

      /// Store identity changes:
      await Future.forEach(_identitiesView.changes(),
          (UserIdentityChange uic) async {
        model.UserIdentity identity = new model.UserIdentity.empty()
          ..userId = u.id
          ..identity = uic.identity;

        if (uic.type == Change.added) {
          await _userController.addIdentity(identity);
        } else if (uic.type == Change.deleted) {
          await _userController.removeIdentity(identity);
        }
      });

      notify.info('Brugeren blev opdateret.');
    } catch (error) {
      notify.error('Der skete en fejl i forbindelse med lagringen af brugeren');
      _log.severe('Save user failed with: ${error}');
    }
  }
}
