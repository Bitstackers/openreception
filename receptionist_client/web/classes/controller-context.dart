part of controller;

abstract class Context {
  
  static void change (UIContext.Context newContext) {
    event.bus.fire(event.locationChanged, new nav.Location.context(newContext.id));
  }
}