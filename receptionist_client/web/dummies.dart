library dummies;

import 'dart:async';
import 'dart:html';

import 'enums.dart';

import 'package:openreception_framework/bus.dart';

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

  CalendarEvent.Null();

  bool get isNull => id == null;

  Map toJson() {
    return {'id'         : id,
            'contactId'  : contactId,
            'receptionId': receptionId,
            'content'    : content};
  }
}

/**
 * Dummy reception command class
 */
class Command {
  String command;

  Command.fromJson(Map json) {
    command = json['command'];
  }

  Map toJson() {
    return {'command': command};
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
  List<Command> commands = new List<Command>();
  int           id;
  String        name;

  Reception(int this.id, String this.name, this.commands);

  Reception.fromJson(Map json) {
    (json['commands'] as Iterable).forEach((Map item) {
      commands.add(new Command.fromJson(item));
    });
    id       = json['id'];
    name     = json['name'];
  }

  Reception.Null();

  bool get isNull => name == null;

  Map toJson() => {'commands': commands, 'id': id, 'name': name};
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