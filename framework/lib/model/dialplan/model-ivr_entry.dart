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

/// Abstract model super-class for an IVR menu entry.
///
/// Provides an interface for concrete IVR menu entries.
abstract class IvrEntry {
  /// The digits that trigger the execution of this [IvrEntry].
  String get digits;

  /// Parses and creates a concrete [IvrEntry] specialization object from
  /// a [String] [buffer].
  ///
  /// The returned object may, for instance, be a [IvrTransfer] or
  /// [IvrVoicemail] entry.
  static IvrEntry parse(String buffer) {
    final int separator = buffer.indexOf(':');

    String digit =
        buffer.substring(0, separator > 0 ? separator : buffer.length).trim();

    if (digit.length != 1) {
      throw new FormatException('Bad digit length: ${digit.length}', buffer);
    }

    buffer = buffer.substring(separator + 1).trimLeft();

    final int nextTerminator = buffer.indexOf(' ');

    String action = buffer.substring(
        0, nextTerminator > 0 ? nextTerminator : buffer.length);

    switch (action) {
      case key.ivrTopmenu:
        return new IvrTopmenu(digit);

      case key.ivrSubmenu:
        buffer = buffer.substring(nextTerminator + 1).trimLeft();
        return new IvrSubmenu(digit, buffer.split(' ').first);

      case key.transfer:
        return new IvrTransfer(digit, Transfer.parse(buffer));

      case key.voicemail:
        return new IvrVoicemail(digit, Voicemail.parse(buffer));

      case key.reception:
        return new IvrReceptionTransfer(digit, ReceptionTransfer.parse(buffer));

      default:
        throw new FormatException('Undefined action', action);
    }
  }

  /// Serialization function.
  dynamic toJson();

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) =>
      other is IvrEntry && this.toString() == other.toString();
}
