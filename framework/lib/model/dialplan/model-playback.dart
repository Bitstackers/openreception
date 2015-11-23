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
  final String note;

  static const Playback none = const Playback('');

  /**
   * Parsing factory.
   */
  static Playback parse(String buffer) {
    /// Remove leading spaces.
    buffer = buffer.trimLeft();

    bool lock = false;
    String filename;
    String note = '';

    buffer = consumeKey(buffer, Key.playback).trimLeft();

    if (buffer
        .substring(0, Key.lock.length)
        .toLowerCase()
        .startsWith(Key.lock.toLowerCase())) {
      lock = true;
      buffer = buffer.substring(Key.lock.length).trimLeft();
    }

    if(!buffer.startsWith('(')) {
      var consumed = consumeWord(buffer);

      buffer = consumed.buffer;
      filename = consumed.iden;
    }

    int openBracket = buffer.indexOf('(');

    if (openBracket != -1) {
      int closeBracket =
          buffer.indexOf(')') > 0 ? buffer.indexOf(')') : buffer.length;
      note = buffer.substring(openBracket + 1, closeBracket);
    }

    return new Playback(filename, wrapInLock: lock, note: note);
  }

  /**
   *
   */
  const Playback(String this.filename,
      {bool this.wrapInLock: true, String this.note: ''});

  /**
   *
   */
  @override
  operator ==(Playback other) => this.filename == other.filename;

  /**
   *
   */
  @override
  String toString() =>
      'Playback${wrapInLock? ' ${Key.lock}' :''} file ${filename}';

  /**
   *
   */
  @override
  String toJson() => '${Key.playback}${wrapInLock? ' ${Key.lock}' :''}'
      ' $filename ${note.isNotEmpty ? ' ($note)': ''}';
}
