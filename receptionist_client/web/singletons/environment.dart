library environment;

import 'dart:html';

import '../classes/section.dart';

class Environment {
  static Environment _instance;

  factory Environment() {
    if(_instance == null) {
      _instance = new Environment._internal();
    }
    return _instance;
  }

  Environment._internal();
}

final Environment environment = new Environment();
