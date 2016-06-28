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

List<FormatException> validateIvrMenu(IvrMenu menu) {
  List<FormatException> errors = [];

  if (menu.name.isEmpty) {
    errors.add(new FormatException('Menu name should not be empty'));
  }

  if (menu.entries == null) {
    errors.add(new FormatException('Menu entries may not be null'));
  }

  if (menu.greetingLong.filename.isEmpty) {
    errors.add(new FormatException('Greeting should be non-empty'));
  }

  menu.entries.forEach((entry) {
    if (menu.entries.where((e) => e.digits == entry.digits).length > 1) {
      errors.add(new FormatException('Duplicate digit ${entry.digits}'));
    }
  });

  errors.addAll(menu.submenus.map(validateIvrMenu).fold(
      new List<FormatException>(),
      (List<FormatException> list, e) => list..addAll(e)));

  return errors;
}

/**
 * Class representing an IVR menu.
 */
class IvrMenu {
  /// Name of IVR menu.
  String name;

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
   * Extracts the contained [Action] objects from the menu.
   */
  Iterable<Action> get allActions {
    final actions = new List<Action>();

    entries.fold(actions, (List<Action> list, entry) {
      if (entry is IvrTransfer) {
        list.add(entry.transfer);
      } else if (entry is IvrVoicemail) {
        list.add(entry.voicemail);
      } else if (entry is IvrReceptionTransfer) {
        list.add(entry.transfer);
      } else if (entry is IvrSubmenu || entry is IvrTopmenu) {} else
        throw new StateError('Unknown type in entries: ${entry.runtimeType}');

      return list;
    });

    return actions;
  }

  /**
   * Decoding factory method.
   */
  static IvrMenu decode(Map map) => (new IvrMenu(
      map[Key.name],
      Playback.parse(map[Key
          .greeting])).._greetingShort = Playback.parse(map[Key.greetingShort]))
    ..entries = new List.from(map[Key.ivrEntries].map(IvrEntry.parse))
    ..submenus = new List.from(map[Key.submenus].map(IvrMenu.decode));

  /**
   * An IVR menu equals another IVR menu if their names match.
   */
  @override
  bool operator ==(Object other) => other is IvrMenu && this.name == other.name;

  /**
   * Serialization function.
   */
  Map toJson() => {
        Key.name: name,
        Key.greeting: greetingLong.toJson(),
        Key.greetingShort: greetingShort.toJson(),
        Key.ivrEntries:
            entries.map((entry) => entry.toJson()).toList(growable: false),
        Key.submenus:
            submenus.map((entry) => entry.toJson()).toList(growable: false)
      };
}
