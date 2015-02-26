part of controller;

abstract class Context {
  static void change (UIContext.Context newContext) {
    event.bus.fire(event.contextChanged, newContext);
    Context.changeLocation(new nav.Location.context(newContext.id));
  }

  static void changeLocation (nav.Location newLocation) {
    event.bus.fire(event.locationChanged, newLocation);
  }
}
