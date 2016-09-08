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

/// Class representing a voicemail action. Used in the itermediate
/// representation for signifying the voicemail action.
///
/// Serializes to a single-line human-readable string format that may be
/// used in a diaplan language.
class Voicemail implements Action {
  /// The name of the voicemail account.
  final String vmBox;

  /// Descriptive note for this [Voicemail] action.
  String note = '';

  /// The recipient email address.
  String recipient = '';

  /// Default constructor.
  Voicemail(this.vmBox, {this.recipient: '', this.note: ''});

  /// Parses and creates a new [Voicemail] action from a [String] [buffer].
  static Voicemail parse(String buffer) {
    String vmBox = '';
    String recipient = '';
    String note = '';

    /// Keyword.
    buffer = _consumeKey(buffer, key.voicemail).trimLeft();

    /// Voicemail box.
    _ConsumedIdenBuf consumed = consumeWord(buffer);
    vmBox = consumed.iden;
    buffer = consumed.buffer.trimLeft();

    /// Check for comments, or consume recipient.
    if (buffer.startsWith('(')) {
      _ConsumedCommentBuf consumedComment = consumeComment(buffer);
      note = consumedComment.comment;
    } else {
      consumed = consumeWord(buffer);
      recipient = consumed.iden;
    }

    /// Remove consumed parts from the buffer.
    buffer = consumed.buffer.trimLeft();

    /// Check for comments.
    if (buffer.startsWith('(')) {
      _ConsumedCommentBuf consumedComment = consumeComment(buffer);
      note = consumedComment.comment;
    }

    return new Voicemail(vmBox, recipient: recipient, note: note);
  }

  /// Equals ignore [note].
  @override
  bool operator ==(Object other) =>
      other is Voicemail && this.vmBox == other.vmBox;

  @override
  String toString() => 'Voicemail $vmBox';

  @override
  String toJson() => '${key.voicemail} $vmBox'
      '${recipient.isNotEmpty ? ' $recipient' : ''}'
      '${note.isNotEmpty ? ' ($note)' : ''}';

  @override
  int get hashCode => toString().hashCode;
}
