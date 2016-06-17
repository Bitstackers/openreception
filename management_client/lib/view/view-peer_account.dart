part of management_tool.view;

class PeerAccount {
  final DivElement element = new DivElement()
    ..id = 'peer_account-content'
    ..hidden = true;

  final Logger _log = new Logger('$_libraryName.PeerAccount');

  final controller.PeerAccount _peerAccountController;
  final User _userView;

  final InputElement _peernameInput = new InputElement()..id = 'peername';
  final InputElement _passwordInput = new InputElement()..id = 'peer-password';
  final InputElement _contextInput = new InputElement()..id = 'peer-context';

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
    element.children = [
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
            ..htmlFor = _peernameInput.id,
          _contextInput
        ]
        ..hidden = true,
      _deleteButton,
      _deployButton,
    ];
    _observers();
  }

  /**
   *
   */
  void _observers() {
    Iterable<InputElement> inputs =
        element.querySelectorAll('input') as Iterable<InputElement>;

    inputs.forEach((InputElement ine) {
      ine.onInput.listen((_) {
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
  void set account(model.PeerAccount acc) {
    /// Reset labels.
    _deleteButton.text = 'Slet';

    _deleteButton.disabled = acc.username.isNotEmpty;
    _deployButton.disabled = acc.username.isNotEmpty;
    _deleteButton.disabled = !_deployButton.disabled;

    _peernameInput.value = acc.username;
    _passwordInput.value =
        acc.username.isEmpty ? random.randomAlphaNumeric(8) : acc.password;

    show();
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
}
