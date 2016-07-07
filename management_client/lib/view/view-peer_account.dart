part of management_tool.view;

class PeerAccount {
  final DivElement element = new DivElement()
    ..id = 'peer_account-content'
    ..hidden = true;

  final Logger _log = new Logger('$_libraryName.PeerAccount');

  bool get isChanged =>
      _orginalAccount.username != account.username ||
      _orginalAccount.password != account.password ||
      _orginalAccount.context != account.context;

  bool get isNotChanged => !isChanged;

  final controller.PeerAccount _peerAccountController;
  final User _userView;
  model.PeerAccount _orginalAccount;

  final InputElement _peernameInput = new InputElement()..id = 'peername';
  final InputElement _passwordInput = new InputElement()..id = 'peer-password';
  final InputElement _contextInput = new InputElement()
    ..id = 'peer-context'
    ..value = 'receptionists';

  final ButtonElement _deleteButton = new ButtonElement()
    ..text = 'Slet'
    ..classes.add('delete');

  final ButtonElement _deployButton = new ButtonElement()
    ..text = 'Generér SIP konto'
    ..classes.add('deploy');

  void hide() {
    element.hidden = true;
  }

  void show() {
    element.hidden = false;
  }

  /**
   *
   */
  PeerAccount(this._peerAccountController, this._userView) {
    element
      ..children = [
        new DivElement()
          ..children = [
            new LabelElement()
              ..text = 'Lokalnummer'
              ..htmlFor = _peernameInput.id,
            _peernameInput
          ],
        new DivElement()
          ..children = [
            new LabelElement()
              ..text = 'SIP password'
              ..htmlFor = _passwordInput.id,
            _passwordInput
          ],
        new DivElement()
          ..children = [
            new LabelElement()
              ..text = 'Kontekst'
              ..htmlFor = _contextInput.id,
            _contextInput
          ],
        _deleteButton,
        _deployButton,
      ]
      ..hidden = true;
    _observers();
  }

  /**
   *
   */
  void _observers() {
    ElementList<InputElement> inputs = element.querySelectorAll('input');

    inputs.forEach((InputElement ine) {
      ine.onInput.listen((_) {
        element.classes.toggle('changed', isChanged);
        _deployButton.disabled = false;
        _deleteButton.disabled = !_deployButton.disabled;
      });
    });

    _deployButton.onClick.listen((_) async {
      await _deployAccount();
    });

    _deleteButton.onClick.listen((_) {
      _deletePeer();
    });
  }

  ///
  Future loadAccount(String extension) async {
    /// Reset labels.
    _deleteButton.text = 'Slet';

    /// Show component and set loading state
    show();
    loading = true;

    _log.finest('Loading peer account for $extension');

    /// Make a new account and update it later on with a password to trigger
    /// the "isChanged" condition.
    _orginalAccount = new model.PeerAccount(extension, '', 'receptionists');

    if (extension.isNotEmpty) {
      try {
        _orginalAccount = await _peerAccountController.get(extension);
        _passwordInput.value = _orginalAccount.password;
      } on storage.NotFound {}
    }

    _peernameInput.value = _orginalAccount.username;

    _passwordInput.value = _orginalAccount.password.isEmpty
        ? random.randomAlphaNumeric(8)
        : _orginalAccount.password;
    _contextInput.value = _orginalAccount.context;

    loading = false;

    element.classes.toggle('changed', isChanged);
    _deleteButton.disabled = isChanged;
    _deployButton.disabled = isNotChanged;
  }

  /**
   *
   */
  model.PeerAccount get account => new model.PeerAccount(
      _peernameInput.value, _passwordInput.value, _contextInput.value);

  /**
   *
   */
  Future _deletePeer() async {
    _log.finest('Deleting peer account ${account.username}');
    final String confirmationText =
        'Bekræft sletning af konto: ${account.username}?';

    if (_deleteButton.text != confirmationText) {
      _deleteButton.text = confirmationText;
      return;
    }

    try {
      _deleteButton.disabled = true;

      await _peerAccountController.remove(account.username);
      notify.success('Konto slettet', account.username);

      hide();
    } catch (error) {
      notify.error('Konto ikke slettet', 'Fejl: $error');
      _log.severe('Delete account failed with: ${error}');
    }

    _deleteButton.text = 'Slet';
  }

  /**
   *
   */
  Future _deployAccount() async {
    _deployButton.disabled = true;
    _deleteButton.disabled = true;

    try {
      if (account.username.isNotEmpty) {
        await _peerAccountController.deploy(account, _userView.userId);

        notify.success('Konto blev udrullet', account.username);
      }
    } catch (error) {
      notify.error('Kunne ikke udrullet konto', 'Fejl: $error');
      _log.severe('Deploy account failed with: ${error}');
    }
  }

  /**
   * Clear out the input fields of the widget.
   */
  void clear() {
    _peernameInput.value = '';
    _passwordInput.value = '';
    _contextInput.value = '';
  }

  /**
   *
   */
  void set loading(bool isLoading) {
    element.classes.toggle('loading', isLoading);

    ElementList<InputElement> inputs = element.querySelectorAll('input');

    inputs.forEach((InputElement ine) {
      ine.disabled = isLoading;
    });
  }
}
