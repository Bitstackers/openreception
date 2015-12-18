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

Iterable<Playback> playbackActions(ReceptionDialplan rdp) =>
    rdp.allActions.where((a) => a is Playback);

/**
 *
 */
class ReceptionDialplan {

  String extension = 'empty';

  List<HourAction> open = [];

  String note = '';
  bool active = true;

  List<NamedExtension> extraExtensions = [];

  Iterable<Action> get allActions => []
    ..addAll(defaultActions)
    ..addAll(
        open.fold([], (list, HourAction hour) => list..addAll(hour.actions)))
    ..addAll(extraExtensions.fold(
        [], (list, NamedExtension exten) => list..addAll(exten.actions)));

  List<Action> defaultActions = [];

  static ReceptionDialplan decode(Map map) => new ReceptionDialplan()
    ..extension = map['extension']
    ..open = map['open'].map(HourAction.parse).toList()
    ..extraExtensions =
        map['extraExtensions'].map(NamedExtension.decode).toList()
    ..defaultActions = map['closed'].map(Action.parse).toList()
    ..note = map['note']
    ..active = map['active'];

  Map toJson() => {
        'extension': extension,
        'open': open,
        'note': note,
        'active': active,
        'closed': defaultActions,
        'extraExtensions': extraExtensions
      };
}
