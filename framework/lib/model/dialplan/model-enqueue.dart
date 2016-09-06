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

part of orf.model.dialplan;

/// Model class for [Enqueue] dialplan action.
///
/// This action will enqueue a channel in a FIFO queue with [queueName].
class Enqueue implements Action {
  /// The name of the queue to enqueue in.
  final String queueName;

  /// The hold music playlist to playback to the channel while enqueued
  final String holdMusic;

  /// Descriptive note for this [Enqueue] action.
  final String note;

  /// Create a new [Enqueue] action.
  ///
  /// Needs [queueName] and optionally the [holdMusic] and note.
  /// The [holdMusic] defaults to `default` which is merely the default
  /// playlist in FreeSWITCH. The [note] is empty if not supplied.
  Enqueue(this.queueName, {this.holdMusic: 'default', this.note: ''});

  /// Parses and creates a new [Enqueue] action from a [String] [buffer].
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

        buffer = buffer.substring(closeBracket + 1).trimLeft();
      }
    }

    buffer = _consumeKey(buffer, key.enqueue).trimLeft();

    if (buffer.startsWith('(')) {
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
            buffer.length >= key.music.length
                ? key.music.length
                : buffer.length)
        .toLowerCase()
        .startsWith(key.music.toLowerCase())) {
      ///Trim the music keyword.
      buffer = buffer.substring(key.music.length).trimLeft();

      int nextSpace =
          buffer.indexOf(' ') > 0 ? buffer.indexOf(' ') : buffer.length;
      music = buffer.substring(0, nextSpace).trimRight();

      buffer = buffer.substring(nextSpace).trimLeft();
    }

    if (buffer.isNotEmpty) {
      consumeNote();
    }

    return new Enqueue(queuename, holdMusic: music, note: note);
  }

  /// Serialization function.
  @override
  String toJson() => '${key.enqueue} $queueName'
      '${holdMusic.isNotEmpty ? ' music $holdMusic' : ''}';

  /// An [Enqueue] action is equal to another [Enqueue] action if their
  /// [queueName]s are identitical.
  @override
  bool operator ==(Object other) =>
      other is Enqueue && this.queueName == other.queueName;

  /// The hashcode [Enqueue] action is equal to another [Enqueue] action if
  /// their [queueName]s are identitical.
  @override
  int get hashCode => this.queueName.hashCode;
}
