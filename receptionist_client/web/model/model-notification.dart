part of model;

/**
 * TODO: Write up documentation for this class and refer to wiki page.
 */

int _sequence   =  0;

int get nextInSequence => _sequence++;

abstract class NotificationType {
  static const String Warning = 'warning';
  static const String Error   = 'error';
  static const String Success = 'success';
  static const String Notice  = 'notice';
}

class Notification {

  static final className = '${libraryName}.Notification';

  final DateTime timestamp = new DateTime.now();
  final int      _ID       = nextInSequence;
  final String   _message;
  final String   type;

  int    get ID      => this._ID;
  String get message => this._message;

  Notification (this._message, {String this.type : NotificationType.Warning});

  @override
  String toString() {
    return this._message;
  }

}