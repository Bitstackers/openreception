part of openreception.model;

class Reception {

  static const int noID = 0;

  int ID = noID;

  Reception.fromMap(Map receptionMap) {
    throw new StateError('Not implemented');
  }

  Map get asMap =>
    throw new StateError('Not implemented');
}
