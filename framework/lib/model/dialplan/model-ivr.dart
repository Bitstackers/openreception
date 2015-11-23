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

class Ivr extends Action {
  final String menuName;
  final String note;

  Ivr(this.menuName, {this.note : ''});

  static Ivr parse(String buffer) {
    var buf = consumeKey(buffer.trimLeft(), Key.ivr).trimLeft();

    var consumed = consumeWord(buf);

    final String menuName = consumed.iden;

    if(menuName.isEmpty) {
      throw new FormatException('Menu name is missing', buffer);
    }
    buf = consumed.buffer;

    final String note = consumeComment(buf).comment;

    return new Ivr(menuName, note : note);
  }

  operator == (Ivr other) => this.menuName == other.menuName;

  String toString() => '${Key.ivr} ${menuName}';

  String toJson() => '${Key.ivr} ${menuName}';

}