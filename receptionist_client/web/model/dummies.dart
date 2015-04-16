library dummies;

import 'dart:async';
import 'dart:html';

import '../enums.dart';

import 'package:openreception_framework/bus.dart';

/**
 * A generic list entry.
 */
class ListEntry<T> {
  T object;

  ListEntry(this.object);
}

/**
 * Dummy application state class
 */
class AppClientState {
  static final AppClientState _singleton = new AppClientState._internal();
  factory AppClientState() => _singleton;

  Bus<AppState> _bus = new Bus<AppState>();

  AppClientState._internal();

  Stream<AppState> get onStateChange => _bus.stream;

  set state(AppState state) => _bus.fire(state);
}

/**
 * Dummy calendar event class
 */
class CalendarEvent {
  int       id          = null;
  int       contactId   = null;
  int       receptionId = null;
  String    content;

  CalendarEvent.fromJson(Map json) {
    id          = json['id'];
    contactId   = json['contactId'];
    receptionId = json['receptionId'];
    content     = json['content'];
  }

  Map toJson() {
    return {'id'         : id,
            'contactId'  : contactId,
            'receptionId': receptionId,
            'content'    : content};
  }
}

/**
 * Dummy contact class
 */
class Contact {
  int          id          = null;
  int          receptionId = null;
  String       name;
  List<String> tags;

  LIElement           li = new LIElement()..tabIndex = -1;

//  Contact(String this.name, {List<String> this.tags}) {
//    li.text = name;
//    if(tags == null) {
//      tags = new List<String>();
//    }
//  }
//
//  Contact.fromElement(LIElement element) {
//    if(element != null && element is LIElement) {
//      li = element;
//      name = li.text;
//      tags = li.dataset['tags'].split(',');
//    } else {
//      throw new ArgumentError('element is not a LIElement');
//    }
//  }

  Contact.fromJson(Map json) {
    id          = json['id'];
    receptionId = json['receptionId'];
    name        = json['name'];
    tags        = json['tags'];
  }

  Map toJson() {
    return {'id'         : id,
            'name'       : name,
            'receptionId': receptionId,
            'tags'       : tags};
  }
}

/**
 * Dummy reception class
 */
class Reception {
  LIElement    li = new LIElement()..tabIndex = -1;
  String       name;

  Reception(String this.name) {
    li.text = name;
  }

  Reception.fromElement(LIElement element) {
    if(element != null && element is LIElement) {
      li = element;
      name = li.text;
    } else {
      throw new ArgumentError('element is not a LIElement');
    }
  }
}

/**
 * A dummy telephone number.
 */
class TelNum {
  LIElement   li         = new LIElement()..tabIndex = -1;
  bool        secret;
  SpanElement spanLabel  = new SpanElement();
  SpanElement spanNumber = new SpanElement();

  TelNum(String number, String label, this.secret) {
    if(secret) {
      spanNumber.classes.add('secret');
    }

    spanNumber.text = number;
    spanNumber.classes.add('number');
    spanLabel.text = label;
    spanLabel.classes.add('label');

    li.children.addAll([spanNumber, spanLabel]);
    li.dataset['number'] = number;
  }

  TelNum.fromElement(LIElement element) {
    if(element != null && element is LIElement) {
      li = element;
    } else {
      throw new ArgumentError('element is not a LIElement');
    }
  }
}