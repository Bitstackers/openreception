part of controller;

abstract class User {

  /**
   * Notifies the UI and servers that the receptionist is now ready
   * to handle another call.
   *
   * TODO: Build logic behind this.
   */
  static void signalReady(_) {
    event.bus.fire(event.receptionChanged, Model.nullReception);
  }

}