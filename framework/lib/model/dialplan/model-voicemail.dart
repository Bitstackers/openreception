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

class Voicemail extends Action {
  final String vmBox;
  String note = '';
  String recipient = '';

  Voicemail(this.vmBox, {this.recipient: '', this.note: ''});

  static Voicemail parse(String buffer) {
    String vmBox = '';
    String recipient = '';
    String note = '';
    buffer = consumeKey(buffer, Key.voicemail).trimLeft();

    var consumed = consumeWord(buffer);
    vmBox = consumed.iden;
    buffer = consumed.buffer.trimLeft();

    if (buffer.startsWith('(')) {
      consumed = consumeComment(buffer);
      note = consumed.comment;
    } else {
      consumed = consumeWord(buffer);
      recipient = consumed.iden;
    }

    buffer = consumed.buffer.trimLeft();

    if (buffer.startsWith('(')) {
      consumed = consumeComment(buffer);
      note = consumed.comment;
    }

    return new Voicemail(vmBox, recipient: recipient, note: note);
  }

  operator ==(Voicemail other) => this.vmBox == other.vmBox;

  String toString() => 'Voicemail $vmBox';

  String toJson() => '${Key.voicemail} $vmBox'
      '${recipient.isNotEmpty ? '${recipient}' : ''}';
}
