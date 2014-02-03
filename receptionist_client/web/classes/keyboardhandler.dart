/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library keyboard;

import 'dart:async';
import 'dart:html';

import 'events.dart' as event;
import 'id.dart' as id;
import 'location.dart' as nav;
import 'logger.dart';
import 'model.dart' as model;

import 'package:ctrl_alt_foo/keys.dart' as ctrlAlt;

final _KeyboardHandler keyboardHandler = new _KeyboardHandler();

/**
 * [Keys] is a simple mapping between constant literals and integer key codes.
 */
class Keys {
  static const int TAB   =  9;
  static const int ENTER = 13;
  static const int SHIFT = 16;
  static const int CTRL  = 17;
  static const int ALT   = 18;
  static const int ESC   = 27;
  static const int SPACE = 32;
  static const int UP    = 38;
  static const int DOWN  = 40;
  static const int ZERO  = 48;
  static const int ONE   = 49;
  static const int TWO   = 50;
  static const int THREE = 51;
  static const int FOUR  = 52;
  static const int FIVE  = 53;
  static const int SIX   = 54;
  static const int SEVEN = 55;
  static const int EIGHT = 56;
  static const int A     = 65;
  static const int B     = 66;
  static const int C     = 67;
  static const int D     = 68;
  static const int E     = 69;
  static const int F     = 70;
  static const int G     = 71;
  static const int H     = 72;
  static const int I     = 73;
  static const int J     = 74;
  static const int K     = 75;
  static const int L     = 76;
  static const int M     = 77;
  static const int N     = 78;
  static const int O     = 79;
  static const int P     = 80;
  static const int Q     = 81;
  static const int R     = 82;
  static const int S     = 83;
  static const int T     = 84;
  static const int U     = 85;
  static const int V     = 86;
  static const int W     = 87;
  static const int X     = 88;
  static const int Y     = 89;
  static const int Z     = 90;
}

/**
 * [_KeyboardHandler] handles sinking of keycodes on associated streams. User of
 * this class may subscribe to these streams using the [onKeyName] method.
 *
 * Using this class guarantees that only ONE key event at a time is processed.
 *
 * NOTE: It is up to the users of this class to decide whether to react on a
 * key events or not. This class merely dump the keycodes of fired key events on
 * a stream.
 */
class _KeyboardHandler {
  Map<int, String>                   _keyToName           = new Map<int, String>();
  Map<String, StreamController<int>> _StreamControllerMap = new Map<String, StreamController<int>>();
  int                                _locked              = null;
  nav.Location                       _currentLocation;
  
  List<nav.Location> ContextHome;
  Map<nav.Location, int> ContextHomeMap;
  
  List<nav.Location> contextHomeNoReception = 
      [new nav.Location(id.CONTEXT_HOME, id.COMPANY_SELECTOR, id.COMPANY_SELECTOR_SEARCHBAR),
       new nav.Location(id.CONTEXT_HOME, id.GLOBAL_QUEUE),
       new nav.Location(id.CONTEXT_HOME, id.LOCAL_QUEUE)];
  
  List<nav.Location> contextHomeReception = 
      [new nav.Location(id.CONTEXT_HOME, id.COMPANY_SELECTOR, id.COMPANY_SELECTOR_SEARCHBAR),
       new nav.Location(id.CONTEXT_HOME, id.COMPANY_EVENTS, id.COMPANY_EVENTS_LIST),
       new nav.Location(id.CONTEXT_HOME, id.COMPANY_HANDLING, id.COMPANY_HANDLING_LIST)
//       new nav.Location(id.CONTEXT_HOME, id.GLOBAL_QUEUE),
//       new nav.Location(id.CONTEXT_HOME, id.LOCAL_QUEUE)
      ];
  
  Map<String, Map<nav.Location, int>> tabMap = 
      {id.CONTEXT_HOME : new Map<nav.Location, int>(),
       id.CONTEXT_MESSAGES : new Map<nav.Location, int>(),
       id.CONTEXT_LOG : new Map<nav.Location, int>(),
       id.CONTEXT_STATISTICS : new Map<nav.Location, int>(),
       id.CONTEXT_PHONE : new Map<nav.Location, int>(),
       id.CONTEXT_VOICEMAILS : new Map<nav.Location, int>()};
//    {'${id.CONTEXT_HOME}.${id.COMPANY_SELECTOR}.${id.COMPANY_SELECTOR_SEARCHBAR}' : 1,
//     '${id.CONTEXT_HOME}.${id.COMPANY_EVENTS}.${id.COMPANY_EVENTS_LIST}'          : 2,
//     '${id.CONTEXT_HOME}.${id.COMPANY_HANDLING}.${id.COMPANY_HANDLING_LIST}'      : 3};
  
  Map<nav.Location, int> contextHomeNoReceptionMap = new Map<nav.Location, int>();
  Map<nav.Location, int> contextHomeReceptionMap = new Map<nav.Location, int>();
  
  /**
   * [KeyboardHandler] constructor.
   * Initialize (setup named streams) and setup listeners for key events.
   */
  _KeyboardHandler() {
    _buildTabMap();
    _ctrlAltInitialize();
  }
  
  /**
   * TODO Blah blah
   */
  void _buildTabMap() {
    for(int index = 0; index < contextHomeNoReception.length; index++) {
      contextHomeNoReceptionMap[contextHomeNoReception[index]] = index;
    }

    for(int index = 0; index < contextHomeReception.length; index++) {
      contextHomeReceptionMap[contextHomeReception[index]] = index;
    }
    
    ContextHome = contextHomeNoReception;
    ContextHomeMap = contextHomeNoReceptionMap;
    //tabMap[id.CONTEXT_HOME] = contextHomeNoReceptionMap;
  }

  void _ctrlAltInitialize() {
    
    event.bus.on(event.receptionChanged).listen((model.Reception reception) {
      ContextHome = reception != model.nullReception ? contextHomeReception : contextHomeNoReception;
      ContextHomeMap = reception != model.nullReception ? contextHomeReceptionMap : contextHomeNoReceptionMap;
    });
    
    event.bus.on(event.locationChanged).listen((nav.Location location) {
      _currentLocation = location;
    });
    
    ctrlAlt.Keys.shortcuts({
      'Ctrl+E'    : () => event.bus.fire(event.locationChanged, new nav.Location(id.CONTEXT_HOME, id.COMPANY_EVENTS, id.COMPANY_EVENTS_LIST)),
      'Ctrl+H'    : () => event.bus.fire(event.locationChanged, new nav.Location(id.CONTEXT_HOME, id.COMPANY_HANDLING, id.COMPANY_HANDLING_LIST)),
      'Ctrl+C'    : () => event.bus.fire(event.locationChanged, new nav.Location(id.CONTEXT_HOME, 'sendmessage', 'sendmessagecellphone')),
      'Ctrl+P'    : () => event.bus.fire(event.pickupNextCall, 'Keyboard'),
      'Tab'       : tabHandler,
      'Shift+Tab' : shiftTabHandler
    });
  }
  
  void tabFoo(Map<nav.Location, int> map, List<nav.Location> list) {
    if(map.containsKey(_currentLocation)) {
      int index = (map[_currentLocation] + 1) % map.length;
      event.bus.fire(event.locationChanged, list[index]); 
      
    } else {
      log.error('keyboard.tabHandler() bad location $_currentLocation');
    }
  }
  
  void tabHandler() {
    switch (_currentLocation.contextId){
      case id.CONTEXT_HOME: 
        tabFoo(ContextHomeMap, ContextHome);
          
    }
    
//    if(tabMap[_currentLocation.contextId].containsKey(_currentLocation)) {
//      int index = (tabMap[_currentLocation.contextId][_currentLocation] + 1) % tabMap.length;
//      
//      event.bus.fire(event.locationChanged, contextHomeReception[index]);      
//    } else {
//      log.error('keyboard.tabHandler() Bad location ${_currentLocation}');
//    }
  }
  
  void shiftTabHandler() {
    if(tabMap[_currentLocation.contextId].containsKey(_currentLocation)) {
      int index = (tabMap[_currentLocation.contextId][_currentLocation] - 1) % tabMap.length;
      event.bus.fire(event.locationChanged, contextHomeReception[index]);      
    } else {
      log.error('keyboard.shiftTabHandler() Bad location ${_currentLocation}');
    }
  }
}
