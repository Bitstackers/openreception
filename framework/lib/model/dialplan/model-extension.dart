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
 *
 */
abstract class Extension {
  String get name;
  List<Action> get actions;

  Map toJson();
}

class NamedExtension extends Extension {
  final String name;
  final List<Action> actions;

  NamedExtension(this.name, this.actions);

  static NamedExtension decode(Map map) => new NamedExtension(
      map[Key.name], map[Key.actions].map(Action.parse).toList());

  Map toJson() => {Key.name: name, Key.actions: actions};
}
