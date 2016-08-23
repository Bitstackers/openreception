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

part of openreception.framework.model.dialplan;

class Ringtone implements Action {
  final int count;

  factory Ringtone(int count) {
    if (count < 0) {
      throw new ArgumentError.value(
          count, 'count', 'Count must be greater than 0');
    }

    return new Ringtone._internal(count);
  }

  const Ringtone._internal(this.count);

  static Ringtone parse(String buffer) {
    var buf = consumeKey(buffer.trimLeft(), key.ringtone).trimLeft();

    var consumed = consumeWord(buf);

    int count;
    try {
      count = int.parse(consumed.iden);
    } on FormatException {
      throw new FormatException('${consumed.iden} is not an integer', buffer);
    }

    buf = consumed.buffer;

    return new Ringtone(count);
  }

  @override
  String toJson() => '${key.ringtone} $count';
}
