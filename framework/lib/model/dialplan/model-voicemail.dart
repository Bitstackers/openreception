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

/**
 * Class representing a voicemail action. Used in the itermediate representation
 * for signifying the voicemail action. Serializes to a single-line
 * human-readable string format that may be used in a diaplan language.
 */
class Voicemail extends Action {
  final String vmBox;
  String note = '';
  String recipient = '';

  /**
   * Default constructor.
   */
  Voicemail(this.vmBox, {this.recipient: '', this.note: ''});

  /**
   *
   */
  static Voicemail parse(String buffer) {
    String vmBox = '';
    String recipient = '';
    String note = '';

    /// Keyword.
    buffer = consumeKey(buffer, Key.voicemail).trimLeft();

    /// Voicemail box.
    var consumed = consumeWord(buffer);
    vmBox = consumed.iden;
    buffer = consumed.buffer.trimLeft();

    /// Check for comments, or consume recipient.
    if (buffer.startsWith('(')) {
      var consumedComment = consumeComment(buffer);
      note = consumedComment.comment;
    } else {
      consumed = consumeWord(buffer);
      recipient = consumed.iden;
    }

    /// Remove consumed parts from the buffer.
    buffer = consumed.buffer.trimLeft();

    /// Check for comments.
    if (buffer.startsWith('(')) {
      var consumedComment = consumeComment(buffer);
      note = consumedComment.comment;
    }

    return new Voicemail(vmBox, recipient: recipient, note: note);
  }

  /**
   *
   */
  operator ==(Voicemail other) => this.vmBox == other.vmBox;

  /**
   *
   */
  String toString() => 'Voicemail $vmBox';

  /**
   *
   */
  String toJson() => '${Key.voicemail} $vmBox'
      '${recipient.isNotEmpty ? ' ${recipient}' : ''}'
      '${note.isNotEmpty ? ' (${note})' : ''}';
}
