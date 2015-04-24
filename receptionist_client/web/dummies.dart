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

  Map toJson() => {'id'         : id,
                   'contactId'  : contactId,
                   'receptionId': receptionId,
                   'content'    : content};
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

  Map toJson() => {'id'         : id,
                   'name'       : name,
                   'receptionId': receptionId,
                   'tags'       : tags};
}

/**
 * Dummy reception class
 */
class Reception {
  List<String> commands     = new List<String>();
  int          id;
  String       name         = '';
  List<String> openingHours = new List<String>();
  String       product      = '';
  List<String> salesMen     = new List<String>();

  Reception(int this.id, String this.name);

  Reception.fromJson(Map json) {
    (json['commands'] as Iterable).forEach((String item) {
      commands.add(item);
    });
    id       = json['id'];
    name     = json['name'];
    (json['openingHours'] as Iterable).forEach((String item) {
      openingHours.add(item);
    });
    product  = json['product'];
    (json['salesMen'] as Iterable).forEach((String item) {
      salesMen.add(item);
    });
  }

  Reception.Null();

  bool get isNull => name.isEmpty || name == null;

  Map toJson() => {'commands'    : commands,
                   'id'          : id,
                   'name'        : name,
                   'openingHours': openingHours,
                   'product'     : product,
                   'salesMen'    : salesMen};
}

/**
 * A dummy telephone number.
 */
class TelNum {
  int    id;
  String label;
  String number;
  bool   secret;

  TelNum(this.id, String this.number, String this.label, this.secret);

  TelNum.fromJson(Map json) {
    id     = json['id'];
    label  = json['label'];
    number = json['number'];
    secret = json['secret'];
  }

  TelNum.Null();

  Map toJson() => {'id'    : id,
                   'label' : label,
                   'number': number,
                   'secret': secret};
}
