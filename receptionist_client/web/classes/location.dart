library location;

import 'dart:html';
import 'dart:math' show pow;

import 'events.dart' as event;
import 'id.dart' as id;
import 'logger.dart';

Map<String, Location> _history = {};

HtmlDocument doc = window.document;

class Location {
  bool   _pushable = true;
  String _contextId;
  String _elementId;
  int    _hashCode;
  String _widgetId;
  
  String get contextId => _contextId;
  String get elementId => _elementId;
  int    get hashCode  => _hashCode;
  String get widgetId  => _widgetId;  
  
  Location._internal(String this._contextId, String this._widgetId, String this._elementId) {
    _hashCode = _calculateHashCode();
    _pushable = true;
  }
  
  factory Location(String contextId, String widgetId, [String elementId]) {
    Element contextElement = querySelector('section#$contextId');
    print('Location.dart -------------- $contextElement - $contextId');
    
    if (elementId != null && elementId.trim().isEmpty) {
      elementId = null;
    }
    return new Location._internal(contextId, widgetId, elementId);
  }
  
  Location.context(String this._contextId) {
    if(_history.containsKey(_contextId)) {
      Location location = _history[_contextId];
      _widgetId = location._widgetId;
      _elementId = location._elementId;
      _hashCode = _calculateHashCode();
    } else {
      log.error('Location.context Unknow context: "${_contextId}"');
    }
  }
  
  Location.fromPopState(String hash) {
    //TODO Validate
    List<String> fragments = hash.substring(1).split('/');
    List<String> addressSegments = fragments[0].split('.');
    _contextId = addressSegments.elementAt(0);
    _widgetId = addressSegments.elementAt(1);
    if(addressSegments.length > 2) {
      _elementId = addressSegments.elementAt(2);
    }
    _hashCode = _calculateHashCode();
    _pushable = false;
  }

  bool operator==(Location other) => contextId == other.contextId && widgetId == other.widgetId && elementId == other.elementId;
  
  int _calculateHashCode() => int.parse(('$_contextId$_widgetId$_elementId').codeUnits.join('')) % pow(2, 31);
  
  /**
   * Update the url bar.
   */
  void push() {
    if(_pushable) {
      if(_elementId != null) {
        doc.title = 'Bob - ${_contextId}.${_widgetId}.${_elementId}';
        window.history.pushState(null, '${_contextId}.${_widgetId}.${_elementId}', '#${_contextId}.${_widgetId}.${_elementId}');
        
      } else {
        doc.title = 'Bob - ${_contextId}.${_widgetId}';
        window.history.pushState(null, '${_contextId}.${_widgetId}', '#${_contextId}.${_widgetId}');
      }
    }
  }
  
  String toString() => '$_contextId.$_widgetId.$_elementId';
}

//TODO Thomas Løcke DO SOMETHING! MAKE IT PRETTY. 
void initialize() {
  List<HtmlElement> contexts = querySelectorAll('#bobactive > section');
  for (HtmlElement context in contexts) {
    if (context.attributes.containsKey('data-default-widget')) {
      String widgetId = context.attributes['data-default-widget'];
      if (context.querySelector('#$widgetId') != null) {
        if (context.querySelector('#$widgetId').attributes.containsKey('data-default-element')) {
          String elementId = context.querySelector('#$widgetId').attributes['data-default-element'];
          if (querySelector('#$elementId') != null) {
            _history[context.id] = new Location(context.id, widgetId, elementId);
          } else {
            log.error('location.initialize() Widget ${widgetId} has bad default element');
          }
        } else {
          _history[context.id] = new Location(context.id, widgetId);
        }        
      } else {
        log.error('location.initialize() Context ${context.id} has bad default widget');
      }
    } else {
      log.error('location.initialize() Context ${context.id} is missing default widget');
    } 
  }
}

void registerOnPopStateListeners() {
  window.onPopState.listen((PopStateEvent stateEvent) {
    _emitWindowLocation();
  });
  
  event.bus.on(event.locationChanged).listen((Location value) {
    _history[value._contextId] = value;
    value.push();
  });
  
  _emitWindowLocation();
}

void _emitWindowLocation() {
  String hash = window.location.hash;
  if(hash.isEmpty) {
    event.bus.fire(event.locationChanged, new Location.context(id.CONTEXT_HOME));
  } else {
    event.bus.fire(event.locationChanged, new Location.fromPopState(hash));
  }
}
