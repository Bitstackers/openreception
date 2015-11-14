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

/**
 * The [AgentHistory] model maintains [AgentStatistics] associated with the
 * agents currently signed in to the system.
 */
class AgentHistory extends IterableBase<ORModel.AgentStatistics> {
  static final instance = new AgentHistory();

  Logger _log = new Logger('$libraryName.AgentHistory');

  Map<int, List<DateTime>> _recentActivity = {};
  Map<int, int> _callsHandledToday = {};

  final Duration _period = new Duration(minutes: 1);
  final Duration _recent = new Duration(hours: 1);
  DateTime _lastRun = new DateTime.now();

  AgentHistory() {
    new Timer.periodic(_period, _housekeeping);
  }

  void _housekeeping(_) {
    final DateTime now = new DateTime.now();

    if (_lastRun.day != now.day) {
      log.info('Day changed - emptying totals');
      _callsHandledToday = {};
    }

    _recentActivity.forEach((int key, List<DateTime> times) {
      Iterable<DateTime> expired =
          times.where((DateTime time) => now.isAfter(time.add(_recent)));

      _callsHandledToday.containsKey(key)
          ? _callsHandledToday[key] = _callsHandledToday[key] + expired.length
          : _callsHandledToday[key] = expired.length;

      times.removeWhere((DateTime time) => now.isAfter(time.add(_recent)));
    });

    _lastRun = now;
  }

  Iterator<ORModel.AgentStatistics> get
    iterator => _recentActivity.keys.map(sumUp).iterator;

  ORModel.AgentStatistics sumUp(int uid) =>
      !_recentActivity.containsKey(uid)
      ? throw new ORStorage.NotFound()
      :


      new ORModel.AgentStatistics(
      uid,
      _recentActivity[uid].length,
      _recentActivity[uid].length +
          (_callsHandledToday.containsKey(uid) ? _callsHandledToday[uid] : 0));

  callHandledByAgent(int userId) => _recentActivity.containsKey(userId)
      ? _recentActivity[userId].add(new DateTime.now())
      : _recentActivity[userId] = (new List()..add(new DateTime.now()));

  List toJson() => this.toList(growable: false);
}
