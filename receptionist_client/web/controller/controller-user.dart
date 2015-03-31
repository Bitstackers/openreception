part of controller;

/**
 * TODO (TL): Missing description of class and what it does.
 */
class User {
  static final User _singleton = new User._internal();
  factory User() => _singleton;

  HotKeys               _hotKeys = new HotKeys();
  Bus<Model.UserStatus> _idle    = new Bus<Model.UserStatus>();
  Bus<Model.UserStatus> _paused  = new Bus<Model.UserStatus>();

  Stream<Model.UserStatus> get onIdle   => _idle.stream;
  Stream<Model.UserStatus> get onPaused => _paused.stream;

  /**
   * User constructor.
   */
  User._internal() {
    _registerEventListeners();
  }

  /**
   * Register listeners for outside events that we care about.
   */
  _registerEventListeners() {
    _hotKeys.onCtrlAltEnter.listen((_) => _setIdle());
    _hotKeys.onCtrlAltP    .listen((_) => _setPaused());
  }

  /**
   * Set the user idle.
   *
   * TODO (TL): Proper error handling. We're not doing anything with errors from
   * the Service.Call.markUserStateIdle Future.
   */
  void _setIdle() {
    Service.Call.instance.markUserStateIdle(Model.User.currentUser.ID).then(_idle.fire);
  }

  /**
   * Set the user paused.
   *
   * TODO (TL): Proper error handling. We're not doing anyting with errors from
   * the Service.Call.markUserStatePaused Future.
   */
  void _setPaused() {
    Service.Call.instance.markUserStatePaused(Model.User.currentUser.ID).then(_paused.fire);
  }
}
