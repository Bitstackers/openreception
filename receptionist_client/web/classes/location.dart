/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library location;

import 'dart:html';
import 'dart:math' show pow;

import 'constants.dart';
import 'events.dart' as event;
import 'logger.dart';

Map<String, Location> _history = {};
Location appDefaultLocation;

HtmlDocument doc = window.document;

class Location {
  String _contextId;
  String _elementId;
  int    _hashCode;
  bool   _pushable = true;
  String _widgetId;

  String get contextId => _contextId;
  String get elementId => _elementId;
  int    get hashCode  => _hashCode;
  String get widgetId  => _widgetId;

  Location._internal(String this._contextId, String this._widgetId, String this._elementId) {
    _hashCode = _calculateHashCode();
  }

  factory Location(String contextId, String widgetId, String elementId) {
    if (validLocation(contextId, widgetId, elementId)) {
      return new Location._internal(contextId, widgetId, elementId);

    } else {
      return appDefaultLocation;
    }
  }

  /**
   * Make a location based on context, and choose the last used widget in the context.
   */
  factory Location.context(String contextId) {
    if(_history.containsKey(contextId)) {
      return _history[contextId];

    } else {
      log.error('Location.context unknown context "${contextId}"');
      return appDefaultLocation;
    }
  }

  /***
   * Make a [Location] from the hash in the URL.
   */
  factory Location.fromPopState(String hash) {
    try {
      List<String> fragments = hash.substring(1).split('/');
      List<String> addressSegments = fragments[0].split('.');

      String contextId = addressSegments.elementAt(0);
      String widgetId = addressSegments.elementAt(1);
      String elementId = addressSegments.elementAt(2);

      if(validLocation(contextId, widgetId, elementId)) {
        return new Location(contextId, widgetId, elementId)
          .._pushable = false;

      } else {
        throw('invalid hash');
      }

    } catch(error) {
      log.error('location.Location.fromPopState() threw ${error} "${hash}" returning default "${appDefaultLocation}"');
      return new Location(appDefaultLocation.contextId, appDefaultLocation.widgetId, appDefaultLocation.elementId)
        .._pushable = false;
    }
  }

  bool targets (Element element) => this.widgetId == element.id;
  bool operator==(Location other) => contextId == other.contextId && widgetId == other.widgetId && elementId == other.elementId;

  int _calculateHashCode() => int.parse(('$_contextId$_widgetId$_elementId').codeUnits.join('')) % pow(2, 31);

  bool setFocusState(Element widget, Element element) {
    bool active = widgetId == widget.id && elementId == element.id;
    widget.classes.toggle(CssClass.focus, active);
    if(active) {
      element.focus();
    }
    return active;
  }

  /**
   * Determines whether or a widget is currently selected.
   */
  static isActive (Element widget) => widget.classes.contains(CssClass.focus);

  /**
   * Updates the url bar.
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

  static bool validLocation(String contextId, String widgetId, String elementId) {
    Element contextElement = querySelector('section#$contextId');
    if(contextElement == null) {
      log.error('location.Location() bad context "${contextId}" returning default "${appDefaultLocation}"');
      return false;
    }

    Element widgetElement = contextElement.querySelector('#${widgetId}');
    if(widgetElement == null) {
      log.error('location.Location() bad widget "${contextId}.${widgetId}" returning default "${appDefaultLocation}"');
      return false;
    }

    Element elementElement = elementId.isEmpty ? null : widgetElement.querySelector('#${elementId}');
    if(elementElement == null) {
      log.error('location.Location() bad element "${contextId}.${widgetId}.${elementId}" returning default "${appDefaultLocation}"');
      return false;
    }

    return true;
  }
}

/***
 * Inserts the default widgets in the History, for use when no widget, only context, is specified.
 */
void initialize() {
  ElementList<HtmlElement> contexts = querySelectorAll('#${Id.bobActive} > section');
  for (HtmlElement context in contexts) {
    if (context.attributes.containsKey('data-default-widget')) {
      String widgetId = context.attributes['data-default-widget'];
      if (context.querySelector('#$widgetId') != null) {
        if (context.querySelector('#$widgetId').attributes.containsKey('data-default-element')) {
          String elementId = context.querySelector('#$widgetId').attributes['data-default-element'];
          if (querySelector('#$elementId') != null) {
            _history[context.id] = new Location(context.id, widgetId, elementId);
          } else {
            log.critical('location.initialize() Widget ${widgetId} has bad default element');
          }
        } else {
          log.critical('location.initialize() widget ${widgetId} is missing default element');
        }
      } else {
        log.critical('location.initialize() Context ${context.id} has bad default widget');
      }
    } else {
      log.critical('location.initialize() Context ${context.id} is missing default widget');
    }
  }

  appDefaultLocation = _history[Id.contextHome];
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
    event.bus.fire(event.locationChanged, appDefaultLocation);
  } else {
    event.bus.fire(event.locationChanged, new Location.fromPopState(hash));
  }
}
