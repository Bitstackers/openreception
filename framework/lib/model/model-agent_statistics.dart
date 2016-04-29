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

part of openreception.framework.model;

class AgentStatistics {
  final int uid;
  final int recent;
  final int total;

  const AgentStatistics(this.uid, this.recent, this.total);

  AgentStatistics.fromMap(Map map)
      : uid = map[Key.uid],
        recent = map[Key.recent],
        total = map[Key.total];

  static AgentStatistics decode(Map map) => new AgentStatistics.fromMap(map);

  Map toJson() => {Key.uid: uid, Key.recent: recent, Key.total: total};
}
