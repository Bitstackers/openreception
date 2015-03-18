library navigation;

final Navigation home     = new Navigation('context-home', null);
final Navigation homeplus = new Navigation('context-homeplus', null);
final Navigation messages = new Navigation('context-messages', null);

class Navigation {
  String contextId;
  String widgetId;

  Navigation(this.contextId, this.widgetId);
}
