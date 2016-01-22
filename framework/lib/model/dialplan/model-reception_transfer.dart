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
 * ReceptionTransfer action.
 */
class ReceptionTransfer extends Action {
  final String extension;
  final String note;

  /**
   * Default constructor.
   */
  const ReceptionTransfer(this.extension, {this.note: ''});

  static ReceptionTransfer parse(String buffer) {
    /// Remove leading spaces.
    buffer = buffer.trimLeft();

    String extension;
    String note = '';

    buffer = consumeKey(buffer, Key.reception).trimLeft();

    int openBracket = buffer.indexOf('(');

    if (openBracket == -1) {
      extension = buffer.trim();
    } else {
      extension = buffer.substring(0, openBracket).trimRight();

      int closeBracket =
          buffer.indexOf(')') > 0 ? buffer.indexOf(')') : buffer.length;
      note = buffer.substring(openBracket + 1, closeBracket);
    }

    return new ReceptionTransfer(extension, note: note);
  }

  String toString() => 'Transfer to reception $extension ($note)';

  String toJson() => '${Key.reception} $extension'
      '${note.isNotEmpty ? ' ($note)': ''}';
}
