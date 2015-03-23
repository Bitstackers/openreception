library navigation;

import 'dart:async';
import 'dart:html';

import 'package:openreception_framework/bus.dart';

final Map<String, String> _defaultWidget = {'context-home'    : 'reception-calendar',
                                            'context-homeplus': 'reception-alt-names',
                                            'context-messages': 'message-archive-filter'};
final Map<String, String> _widgetHistory = {};

/**
 *
 */
class Place {
  String contextId = null;
  String widgetId  = null;

  Place(String this.contextId, String this.widgetId);

  String toString() => '${contextId}.${widgetId}';
}

/**
 *
 */
class Navigate {
  static final Navigate _singleton = new Navigate._internal();
  factory Navigate() => _singleton;

  Navigate._internal() {
    _registerEventListeners();
  }

  final Bus<Place> _bus = new Bus<Place>();

  /**
   *
   */
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

  /**
   *
   */
  void goWindowLocation() {
    String hash = window.location.hash.substring(1);

    if(hash.isEmpty) {
      _bus.fire(new Place('context-home', null));
    } else {
      final List<String> segments  = hash.split('.');
      final String       contextId = segments.first;
      final String       widgetId  = segments.last;

      _bus.fire(new Place(contextId, widgetId));
    }
  }

  /**
   *
   */
  void goHome() {
    go(new Place('context-home', null));
  }

  /**
   *
   */
  void goHomeplus() {
    go(new Place('context-homeplus', null));
  }

  /**
   *
   */
  void goMessages() {
    go(new Place('context-messages', null));
  }

  /**
   *
   */
  Stream<Place> get onGo => _bus.stream;

  /**
   *
   */
  void _registerEventListeners() {
    window.onPopState.listen((_) => goWindowLocation());
  }
}
