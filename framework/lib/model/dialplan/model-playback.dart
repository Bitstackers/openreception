/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.model.dialplan;

class Playback extends Action {
  final String filename;
  final bool wrapInLock;
  String note = '';
  static final Playback none = new Playback._none();

  Playback.file(String filenameNoExtension, {bool this.wrapInLock : true})
      : this.filename = '$filenameNoExtension.wav';

  Playback.nightGreeting()
   : filename = '\${reception-greeting-closed}',
   wrapInLock = false;

  factory Playback._none() => new Playback.file('');

  Playback.dayGreeting()
    : this.filename = '\${reception-greeting}',
    wrapInLock = true;

  operator == (Playback other) => this.filename == other.filename;

  String toString()  => 'Playback${wrapInLock? ' locked' :''} file ${filename}';


  String toJson() => '${Key.playback} $filename'
      '${note.isNotEmpty ? ' ($note)': ''}';

}