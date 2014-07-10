part of model;

/**
 * TODO: Write up documentation for this class and refer to wiki page.
 */

int _sequence   =  0;

int get nextInSequence {
  return _sequence++;
}

class Notification {
  
  static final className = '${libraryName}.Notification';

  final DateTime timestamp = new DateTime.now();
  final int      _ID       = nextInSequence;
  final String   _message;
  
  int    get ID      => this._ID;
  String get message => this._message;

  Notification (this._message);

  @override
  String toString() {
    return this._message;
  }
  
}