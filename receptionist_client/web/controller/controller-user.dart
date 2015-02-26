part of controller;

abstract class User {
  /**
   * Notifies the UI and servers that the receptionist is now ready
   * to handle another call.
   *
   * TODO: Build logic behind this.
   */
  static void signalReady(_) {
    Service.Call.markUserStateIdle(Model.User.currentUser.ID).then((Model.UserStatus newUserStatus) {
      event.bus.fire(event.userStatusChanged, newUserStatus);
      event.bus.fire(event.receptionChanged, Model.Reception.noReception);
    });

  }

  static void signalPaused(_) {
    Service.Call.markUserStatePaused(Model.User.currentUser.ID).then((Model.UserStatus newUserStatus) {
      event.bus.fire(event.userStatusChanged, newUserStatus);
      event.bus.fire(event.receptionChanged, Model.Reception.noReception);
    });

  }
}
