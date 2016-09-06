part of orm.view;

class UserIdentities {
  final TextAreaElement element = new TextAreaElement();
  final controller.User _userController;
  final Logger _log = new Logger('$_libraryName.UserIdentities');

  /// Change callback handler.
  Function onChange = () => null;

  bool get isChanged => !isNotChanged;

  bool get isNotChanged =>
      identities.toSet().containsAll(_originalIdentities) &&
      _originalIdentities.containsAll(identities.toSet());

  Set<String> _originalIdentities;

  /**
   *
   */
  UserIdentities(this._userController) {
    _observers();
  }

  /**
   *
   */
  void _observers() {
    element.onInput.listen((_) {
      if (onChange != null) {
        onChange();
      }

      element.classes.toggle('changed', isChanged);
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
    element.classes.toggle('changed', false);
  }

  /**
   * Clear out the input fields of the widget.
   */
  void clear() {
    element.value = '';
  }
}
