/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.call_flow_control_server.model;

class AgentHistory extends IterableBase {

  static final instance = new AgentHistory();

  Logger _log = new Logger ('$libraryName.AgentHistory');

  Map<int,List<DateTime>> _recentActivity = {};
  Map<int,int> _callsHandledToday = {};

  final Duration _period = new Duration(minutes : 1);
  final Duration _recent = new Duration(hours : 1);
  DateTime _lastRun = new DateTime.now();

  AgentHistory() {
    new Timer.periodic(_period, _housekeeping);
  }

  void _housekeeping(_) =>
    _recentActivity.forEach((int key, List<DateTime> times) {
      final DateTime now = new DateTime.now();

      if (_lastRun.day != now.day) {
        log.info('Day changed - emptying totals');
        _callsHandledToday = {};
      }

      Iterable<DateTime> expired =times.where((DateTime time) =>
          now.isAfter(time.add(_recent)));

      _callsHandledToday.containsKey(key)
        ? _callsHandledToday[key] = _callsHandledToday[key] + expired.length
        : _callsHandledToday[key] = expired.length;

      times.removeWhere((DateTime time) => now.isAfter(time.add(_recent)));
    });



  Iterator<Map> get iterator => _recentActivity.keys.map
      (_sumUp).iterator;

  Map _sumUp(int uid) => {
    'uid' : uid,
    'recentlyHandled' : _recentActivity[uid].length,
    'total' : _recentActivity[uid].length +
      (_callsHandledToday.containsKey(uid)
      ? _callsHandledToday[uid]
      : 0)
  };

  callHandledByAgent(int userId) =>
      _recentActivity.containsKey(userId)
      ?  _recentActivity[userId].add(new DateTime.now())
      :  _recentActivity[userId] = (new List()..add(new DateTime.now()));

  List toJson() => this.toList(growable : false);
}