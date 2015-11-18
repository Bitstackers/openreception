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

class IvrMenu {
  final String name;
  List<IvrEntry> entries = [];
  final Playback greetingLong;
  Playback _greetingShort = Playback.none;

  List<IvrMenu> submenus = [];

  Playback get greetingShort =>
      _greetingShort != Playback.none ? _greetingShort : greetingLong;

  IvrMenu(this.name, this.greetingLong);

  static IvrMenu decode(Map map) => (new
      IvrMenu(map[Key.ivrMenu][Key.name],
          Playback.parse(map[Key.ivrMenu][Key.greeting]))
          .._greetingShort = Playback.parse(map[Key.ivrMenu][Key.greetingShort]))
          ..entries = map[Key.ivrMenu][Key.ivrEntries].map(IvrEntry.parse).toList();

  operator ==(IvrMenu other) => this.name == other.name;

  Map toJson() => {
        Key.ivrMenu: {
          Key.name: name,
          Key.greeting: greetingLong.toJson(),
          Key.greetingShort: greetingShort.toJson(),
          Key.ivrEntries:
              entries.map((entry) => entry.toJson()).toList(growable: false)
        }
      };
}
