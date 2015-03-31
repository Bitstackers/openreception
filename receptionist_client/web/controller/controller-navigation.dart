part of controller;

/**
 * TODO (TL): Comment
 */
class Place {
  String contextId = null;
  String widgetId  = null;

  Place(String this.contextId, String this.widgetId);

  operator == (Place other) => (this.contextId == other.contextId) && (this.widgetId == other.widgetId);

  String toString() => '${contextId}.${widgetId}';
}

/**
 * TODO (TL): Comment
 */
class Navigate {
  static final Navigate _singleton = new Navigate._internal();
  factory Navigate() => _singleton;

  Navigate._internal() {
    _registerEventListeners();
  }

  final Bus<Place>          _bus           = new Bus<Place>();

  /// TODO (TL): Feels ugly having this map here. Maybe allow widgets to
  /// register themselves? Seems more explicit that way. Hmmm..
  final Map<String, String> _defaultWidget =
    {'context-calendar-edit': 'calendar-editor',
     'context-home'         : 'reception-calendar',
     'context-homeplus'     : 'reception-alt-names',
     'context-messages'     : 'message-archive-filter'};
  final Map<String, String> _widgetHistory = {};

  void go(Place place) {
    if(place.widgetId == null) {
      if(_widgetHistory.containsKey(place.contextId)) {
        place.widgetId = _widgetHistory[place.contextId];
      } else {
        place.widgetId = _defaultWidget[place.contextId];
      }
    }

    _widgetHistory[place.contextId] = place.widgetId;
    window.history.pushState(null, '${place.contextId}.${place.widgetId}', '#${place.contextId}.${place.widgetId}');
    _bus.fire(place);
  }

  void goWindowLocation() {
    String hash = window.location.hash.substring(1);

    if(hash.isEmpty) {
      goHome();
    } else {
      /// TODO (TL): This is really not very robust.
      final List<String> segments  = hash.split('.');
      final String       contextId = segments.first;
      final String       widgetId  = segments.last;

      go(new Place(contextId, widgetId));
    }
  }

  void goCalendarEdit() {go(new Place('context-calendar-edit', null));}
  void goHome() {go(new Place('context-home', null));}
  void goHomeplus() {go(new Place('context-homeplus', null));}
  void goMessages() {go(new Place('context-messages', null));}

  Stream<Place> get onGo => _bus.stream;

  void _registerEventListeners() {
    window.onPopState.listen((_) => goWindowLocation());
  }
}
