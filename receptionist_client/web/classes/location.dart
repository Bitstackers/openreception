library location;

import 'dart:html';

import 'events.dart' as event;
import 'logger.dart';

Map<String, String> contextHistory = 
{ 'contexthome' : 'company-selector-searchbar',
  'contextmessages': 'message-search-agent-searchbar',
  'contextlog': '',
  'contextstatistics':'',
  'contextphone':'phonebooth-company-searchbar',
  'contextvoicemails': ''
};

HtmlDocument doc = window.document;

class Location {
  String contextId;
  String widgetId;
  
  Location(String this.contextId, String this.widgetId);
  
  Location.context(String this.contextId) {
    if(contextHistory.containsKey(contextId)) {
      widgetId = contextHistory[contextId];
    } else {
      log.error('Location.context Unknow context: "${contextId}"');
    }
  }
  
  Location.fromPopState(String hash) {
    List<String> segments = hash.substring(1).split('/');
    contextId = segments.elementAt(0);
    widgetId = segments.elementAt(1);
  }
  
  /**
   * Update the url bar.
   */
  void push() {
    doc.title = 'Bob - ${contextId} / ${widgetId}';
    window.history.pushState(null, '${contextId}/${widgetId}', '#${contextId}/${widgetId}');
  }
}

void registerOnPopStateListeners() {
  window.onPopState.listen((PopStateEvent stateEvent) {
    _emitWindowLocation();
  });
  
  event.bus.on(event.locationChanged).listen((Location value) {
    contextHistory[value.contextId] = value.widgetId;
    value.push();
  });
  
  _emitWindowLocation();
}

void _emitWindowLocation() {
  print('${window.location} ------------------------------------');
  String hash = window.location.hash;
  if(hash.isEmpty) {
    event.bus.fire(event.locationChanged, new Location('contexthome','companyselector'));
  } else {
    event.bus.fire(event.locationChanged, new Location.fromPopState(hash));
  }
}
