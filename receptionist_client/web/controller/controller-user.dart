part of controller;

/**
 * TODO (TL): Missing description of class and what it does.
 */
class User {

  final Service.Call _userStateService;

  User(this._userStateService);

  /**
   * Set the user idle.
   *
   * TODO (TL): Proper error handling. We're not doing anything with errors from
   * the Service.Call.markUserStateIdle Future.
   */
  Future setIdle(Model.User user) =>
    this._userStateService.markUserStateIdle(user);

  /**
   * Set the user paused.
   *
   * TODO (TL): Proper error handling. We're not doing anyting with errors from
   * the Service.Call.markUserStatePaused Future.
   */
  Future setPaused(Model.User user) =>
      this._userStateService.markUserStatePaused(user);

}
