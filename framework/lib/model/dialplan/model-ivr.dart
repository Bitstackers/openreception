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

/// Transfer a channel from a dialplan to the IVR menu application.
class Ivr implements Action {
  /// The name of the menu to transfer the channel to.
  final String menuName;

  /// Descriptive note for this [Ivr] action.
  final String note;

  /// Create a new [Ivr] action that transfers to the IVR menu
  /// named [menuName].
  Ivr(this.menuName, {this.note: ''});

  /// Parses and creates a new [Ivr] action from a [String] [buffer].
  static Ivr parse(String buffer) {
    String buf = _consumeKey(buffer.trimLeft(), key.ivr).trimLeft();

    _ConsumedIdenBuf consumed = consumeWord(buf);

    final String menuName = consumed.iden;

    if (menuName.isEmpty) {
      throw new FormatException('Menu name is missing', buffer);
    }
    buf = consumed.buffer;

    final String note = consumeComment(buf).comment;

    return new Ivr(menuName, note: note);
  }

  @override
  bool operator ==(Object other) =>
      other is Ivr && this.menuName == other.menuName;

  @override
  String toString() => '${key.ivr} $menuName';

  @override
  String toJson() => '${key.ivr} $menuName';

  @override
  int get hashCode => menuName.hashCode;
}
