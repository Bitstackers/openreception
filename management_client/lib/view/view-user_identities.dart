part of management_tool.view;

class UserIdentities {
  final TextAreaElement element = new TextAreaElement();
  final controller.User _userController;
  final Logger _log = new Logger('$_libraryName.UserIdentities');

  Function onChange = () => null;
  bool get changed =>
      _originalIdentities.toSet().difference(_originalIdentities).isNotEmpty;
  Set<String> _originalIdentities;

  UserIdentities(this._userController) {
    _observers();
  }

  void _observers() {
    element.onInput.listen((_) {
      if (onChange != null) {
        onChange();
      }
    });
  }

  /**
   *
   */
  Iterable<String> get identities =>
      element.value.split('\n').map((str) => str.trim());

  /**
   *
   */
  void set identities(Iterable<String> ids) {
    _originalIdentities = ids.toSet();
    element.value = ids.join('\n');
  }
}
