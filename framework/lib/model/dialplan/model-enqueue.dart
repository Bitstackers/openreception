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

class Enqueue implements Action {
  final String queueName;
  final String holdMusic;
  final String note;

  Enqueue(this.queueName, {this.holdMusic: 'default', this.note : ''});

  static Enqueue parse(String buffer) {
    /// Remove leading spaces.
    buffer = buffer.trimLeft();
    String queuename;
    String music = 'default';
    String note = '';

    void consumeNote() {
      int openBracket = buffer.indexOf('(');

      if (openBracket == -1) {
        note = buffer.trim();
      } else {
        note = buffer.substring(0, openBracket).trimRight();

        int closeBracket =
            buffer.indexOf(')') > 0 ? buffer.indexOf(')') : buffer.length;
        note = buffer.substring(openBracket + 1, closeBracket);

        buffer = buffer.substring(closeBracket+1).trimLeft();

      }
    }

    buffer = consumeKey(buffer, Key.enqueue).trimLeft();

    if(buffer.startsWith('(')) {
      consumeNote();
    }

    int nextSpace = buffer.indexOf(' ');
    if (nextSpace == -1) {
      queuename = buffer.trim();

    } else {
      queuename = buffer.substring(0, nextSpace).trimRight();
      buffer = buffer.substring(nextSpace + 1).trimLeft();

    }

    /// Check if there is an occurence of the 'music' keyword.
    if (buffer
        .substring(
            0,
            buffer.length >= Key.music.length
                ? Key.music.length
                : buffer.length)
        .toLowerCase()
        .startsWith(Key.music.toLowerCase())) {
      ///Trim the music keyword.
      buffer = buffer.substring(Key.music.length).trimLeft();

      int nextSpace =
          buffer.indexOf(' ') > 0 ? buffer.indexOf(' ') : buffer.length;
      music = buffer.substring(0, nextSpace).trimRight();

      buffer = buffer.substring(nextSpace).trimLeft();
    }

    if (buffer.isNotEmpty) {
      consumeNote();
    }

    return new Enqueue(queuename, holdMusic: music, note : note);
  }

  String toJson() => '${Key.enqueue} ${queueName}'
      '${holdMusic.isNotEmpty ? ' music $holdMusic' : ''}';
}
