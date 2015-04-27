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
  String       name        = '';
  List<String> tags;

  Contact.fromJson(Map json) {
    id          = json['id'];
    receptionId = json['receptionId'];
    name        = json['name'];
    tags        = json['tags'];
  }

  Contact.Null();

  bool get isNull => name.isEmpty || name == null;

  Map toJson() => {'id'         : id,
                   'name'       : name,
                   'receptionId': receptionId,
                   'tags'       : tags};
}

/**
 * Dummy reception class
 */
class Reception {
  List<String> addresses        = new List<String>();
  List<String> altNames         = new List<String>();
  List<String> bankInfo         = new List<String>();
  List<String> commands         = new List<String>();
  List<String> email            = new List<String>();
  int          id;
  String       miniWikiMarkdown = '';
  String       name             = '';
  List<String> openingHours     = new List<String>();
  String       product          = '';
  List<String> salesMen         = new List<String>();
  List<TelNum> telephoneNumbers = new List<TelNum>();
  List<String> type             = new List<String>();
  List<String> VATNumbers       = new List<String>();
  List<String> websites         = new List<String>();

  Reception(int this.id, String this.name);

  Reception.fromJson(Map json) {
    (json['addresses'] as Iterable).forEach((String item) {
      addresses.add(item);
    });
    (json['altNames'] as Iterable).forEach((String item) {
      altNames.add(item);
    });
    (json['bankInfo'] as Iterable).forEach((String item) {
      bankInfo.add(item);
    });
    (json['commands'] as Iterable).forEach((String item) {
      commands.add(item);
    });
    (json['email'] as Iterable).forEach((String item) {
      email.add(item);
    });

    id               = json['id'];
    miniWikiMarkdown = json['miniWikiMarkdown'];
    name             = json['name'];

    (json['openingHours'] as Iterable).forEach((String item) {
      openingHours.add(item);
    });
    product  = json['product'];
    (json['salesMen'] as Iterable).forEach((String item) {
      salesMen.add(item);
    });
    (json['telephoneNumbers'] as Iterable).forEach((Map json) {
      telephoneNumbers.add(new TelNum.fromJson(json));
    });
    (json['type'] as Iterable).forEach((String item) {
      type.add(item);
    });
    (json['VATNumbers'] as Iterable).forEach((String item) {
      VATNumbers.add(item);
    });
    (json['websites'] as Iterable).forEach((String item) {
      websites.add(item);
    });
  }

  Reception.Null();

  bool get isNull => name.isEmpty || name == null;

  Map toJson() => {'addresses'       : addresses,
                   'altNames'        : altNames,
                   'bankInfo'        : bankInfo,
                   'commands'        : commands,
                   'email'           : email,
                   'id'              : id,
                   'miniWikiMarkdown': miniWikiMarkdown,
                   'name'            : name,
                   'openingHours'    : openingHours,
                   'product'         : product,
                   'salesMen'        : salesMen,
                   'telephoneNumbers': telephoneNumbers,
                   'type'            : type,
                   'VATNumbers'      : VATNumbers,
                   'websites'        : websites};
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
