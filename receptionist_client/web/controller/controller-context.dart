part of controller;

abstract class Context {
  
  static void change (UIContext.Context newContext) {
    Context.changeLocation(new nav.Location.context(newContext.id));
    event.bus.fire(event.contextChanged, newContext);
  }
  
  static void changeLocation (nav.Location newLocation) {
    event.bus.fire(event.locationChanged, newLocation);
  }
  
}