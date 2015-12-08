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
 * Class representing an IVR menu.
 */
class IvrMenu {
  /// ID indicating that this menu is not stored permanently.
  static const int noId = 0;

  /// Database ID.
  int id = noId;

  /// Name of IVR menu.
  final String name;

  /// The entries (different possible actions) of the IVR menu
  List<IvrEntry> entries = [];

  /// The initial greeting of the menu.
  final Playback greetingLong;

  /// Submenus of this menu.
  List<IvrMenu> submenus = [];

  /// The, shorter, greeting for repeating choices.
  Playback get greetingShort =>
      _greetingShort != Playback.none ? _greetingShort : greetingLong;
  Playback _greetingShort = Playback.none;

  /**
   * Default constructor.
   */
  IvrMenu(this.name, this.greetingLong);

  /**
   * Decoding factory method.
   */
  static IvrMenu decode(Map map) =>
      (new IvrMenu(
          map[Key.ivrMenu][Key.name],
      Playback.parse(map[Key.ivrMenu][Key.greeting]))
    ..id = map[Key.ivrMenu][Key.id]
    .._greetingShort = Playback.parse(map[Key.ivrMenu][Key.greetingShort]))
    ..entries = map[Key.ivrMenu][Key.ivrEntries].map(IvrEntry.parse).toList()
    ..submenus = map[Key.ivrMenu][Key.submenus].map(IvrMenu.decode).toList();

  /**
   * An IVR menu equals another IVR menu if their names match.
   */
  operator ==(IvrMenu other) => this.name == other.name;

  /**
   * Serialization function.
   */
  Map toJson() => {
        Key.ivrMenu: {
          Key.id: id,
          Key.name: name,
          Key.greeting: greetingLong.toJson(),
          Key.greetingShort: greetingShort.toJson(),
          Key.ivrEntries:
              entries.map((entry) => entry.toJson()).toList(growable: false),
          Key.submenus:
            submenus.map((entry) => entry.toJson()).toList(growable: false)
        }
      };
}
