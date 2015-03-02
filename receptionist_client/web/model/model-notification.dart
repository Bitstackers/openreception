/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

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

  Notification(this._message, {String this.type : NotificationType.Warning});

  @override
  String toString() {
    return this._message;
  }

}