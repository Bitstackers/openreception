/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.framework.filestore;

final DateFormat _rfc3339 = new DateFormat('yyyy-MM-dd');

class AgentHistory {
  final Logger _log = new Logger('$libraryName.AgentHistory');
  final String path;
  final storage.User _userStore;
  final Map<int, String> _uidNameCache = {};
  final File _uidMapFile;
  final Directory _eventDumpDir;
  final Map<String, model.ActiveCall> _eventHistory = {};
  final Map<String, model.DailyReport> _reports = {};

  Completer _initialized = new Completer();

  factory AgentHistory(
      String path, storage.User userStore, Stream<event.Event> notifications) {
    return new AgentHistory._internal(
        path,
        userStore,
        new File(path + '/uidmappings.json'),
        new Directory(path + '/eventdumps'),
        notifications);
  }

  AgentHistory._internal(this.path, this._userStore, this._uidMapFile,
      this._eventDumpDir, Stream<event.Event> notifications) {
    if (!new Directory(path).existsSync()) {
      _log.info('Creating directory $path');
      new Directory(path).createSync();
    }

    if (!_eventDumpDir.existsSync()) {
      _log.info('Creating directory ${_eventDumpDir.path}');
      _eventDumpDir.createSync();
    }

    if (!new Directory(path + '/reports').existsSync()) {
      _log.info('Creating directory $path/reports');
      new Directory(path + '/reports').createSync();
    }

    if (!_uidMapFile.existsSync()) {
      _uidMapFile.writeAsStringSync('{}');
    }

    notifications.listen((event.Event e) {
      _dispatchEvent(e, _reports);
    });

    new Timer.periodic(new Duration(seconds: 10), (_) => _cleanup());

    _initialize();
  }

  Future get initialized => _initialized.future;

  /**
   *
   */
  Future<model.DailyReport> get(DateTime day) async => _loadReport(day);

  /**
   *
   */
  Stream<List<int>> getRaw(DateTime day) {
    final File f = new File('$path/reports/${_dateKey(day)}.json.gz');
    if (f.existsSync()) {
      return f.readAsBytes().asStream();
    } else {
      throw new NotFound('No report for day ${_dateKey(day)}');
    }
  }

  /**
   *
   */
  Future _initialize() async {
    await _loadUidCacheFile();
    await _updateUidCache();
    await _saveUidCacheFile();
    await _loadEventDumps();

    _initialized.complete();
  }

  /**
   *
   */
  Future _updateUidCache() async {
    Iterable<model.UserReference> uRefs = await _userStore.list();

    uRefs.forEach((uref) {
      _uidNameCache[uref.id] = uref.name;
    });
  }

  void _dispatchEvent(event.Event e, Map<String, model.DailyReport> reports) {
    final dateKey = _rfc3339.format(e.timestamp);

    if (!reports.containsKey(dateKey)) {
      reports[dateKey] = _loadReport(e.timestamp);
    }

    if (e is event.CallEvent) {
      if (!_eventHistory.containsKey(e.call.id)) {
        _eventHistory[e.call.id] = new model.ActiveCall.empty();
      }
      _eventHistory[e.call.id].addEvent(e);

      if (_eventHistory[e.call.id].isDone) {
        reports[dateKey].addCallHistory(_eventHistory[e.call.id]);
      }
    } else if (e is event.MessageChange) {
      reports[dateKey].addMessageHistory(
          new model.MessageHistory(e.mid, e.modifierUid, e.timestamp));
    } else if (e is event.UserState) {
      reports[dateKey].addUserStateChange(new model.UserStateHistory(
          e.status.userId, e.timestamp, e.status.paused));
    } else {
      return;
    }
  }

  /**
   *
   */
  Future _loadEventDumps() async {
    _log.finest('Loading event dumps from ${_eventDumpDir.path}');
    final Map<String, model.DailyReport> _dateLog =
        <String, model.DailyReport>{};

    final Iterable<File> files =
        _eventDumpDir.listSync().where((FileSystemEntity fse) => fse is File);

    files.forEach((file) {
      _log.info('Reading event dump from ${file.path}');
      try {
        List<String> lines = file.readAsLinesSync();

        for (String line in lines) {
          Map<String, dynamic> json = JSON.decode(line) as Map<String, dynamic>;
          event.Event e = new event.Event.parse(json);
          try {
            if (e != null) _dispatchEvent(e, _dateLog);
          } catch (e, s) {
            print(e);
            print(s);
          }
        }

        file.delete();
      } catch (e, s) {
        _log.warning('Could not read event dump from file ${file.path} ', e, s);
      }
    });

    await Future.forEach(_dateLog.values, (report) async {
      await _saveReport(report);
    });

    _log.finest('Read event dumps from ${files.length} files');
  }

  /**
   *
   */
  model.DailyReport _loadReport(DateTime day) {
    final File f = new File('$path/reports/${_dateKey(day)}.json.gz');
    if (f.existsSync()) {
      _log.finest('Loading existing report for ${_dateKey(day)}');
      return new model.DailyReport.fromMap(
          unpackAndDeserializeObject(f.readAsBytesSync()));
    } else {
      _log.finest('Creating new daily report for ${_dateKey(day)}');
      return new model.DailyReport.empty();
    }
  }

  /**
   *
   */
  Future _saveReport(model.DailyReport report) async {
    if (report.isEmpty) {
      _log.info('Refusing to write empty report');
      return;
    }

    final File f = new File('$path/reports/${_dateKey(report.day)}.json.gz');
    _log.finest('Writing report for ${_dateKey(report.day)} to file ${f.path}');
    await f.writeAsBytes(serializeAndCompressObject(report));
  }

  /**
   *
   */
  // Iterable<model.AgentStatisticsSummary> summaries(DateTime day) {
  //   return [];
  // }

  /**
   *
   */
  Future _cleanup() async {
    if (_reports.length > 1) {
      _log.info('Day changed. Rerolling stats');

      final Iterable keysToRemove =
          _reports.keys.where((key) => key != _dateKey(new DateTime.now()));

      for (String key in keysToRemove) {
        await _saveReport(_reports.remove(key));
      }
    } else {
      _log.finest('Updating daily report');
      await _saveReport(_reports[_dateKey(new DateTime.now())]);
    }
  }

  Future<String> lookupUsername(int uid) async {
    await initialized;

    if (!_uidNameCache.containsKey(uid)) {
      try {
        final uRef = await _userStore.get(uid);
        _uidNameCache[uid] = uRef.name;

        await _saveUidCacheFile();
      } on NotFound {
        _log.warning('Failed to located name of uid:$uid. '
            'Consider adding name to cache manually'
            ' (file ${_uidMapFile.path})');
        return '?';
      }
    }
    return _uidNameCache[uid];
  }

  /**
   *
   */
  Future _loadUidCacheFile() async {
    Map deserialized;
    try {
      deserialized = JSON.decode(await _uidMapFile.readAsString());
    } on FormatException {
      _log.shout('Corrupt format for uid -> name mappings in '
          'file ${_uidMapFile.path}');
      return;
    }

    _uidNameCache.clear();
    deserialized.forEach((k, v) {
      try {
        final int uid = int.parse(k);
        _uidNameCache[uid] = v;
      } on FormatException {
        _log.warning('Bad key value $k');
      }
    });

    _log.finest('Loaded ${_uidNameCache.length} uid -> name mappings from '
        'file ${_uidMapFile.path}');
  }

  /**
   *
   */
  Future _saveUidCacheFile() async {
    final Map<String, String> serializable = {};

    _uidNameCache.forEach((k, v) {
      serializable[k.toString()] = v;
    });

    await _uidMapFile.writeAsString(JSON.encode(serializable));
    _log.finest('Saved ${_uidNameCache.length} uid -> name mappings to '
        'file ${_uidMapFile.path}');
  }

  String _dateKey(DateTime day) => _rfc3339.format(day);

  //
  // List<Map<String, dynamic>> agentSummay() {
  //   List<Map<String, dynamic>> ret = [];
  //   callsByAgent.forEach((k, v) {
  //     ret.add({
  //       'uid': k,
  //       'answered': v,
  //       'name': _userNameCache.containsKey(k) ? _userNameCache[k] : '??'
  //     });
  //   });
  //
  //   return ret;
  // }
  //
  // String toString() => 'totalCalls:$totalCalls, '
  //     'below20s:$callsAnsweredWithin20s, '
  //     'oneminute:$callWaitingMoreThanOneMinute, '
  //     'talktime:$talkTime, '
  //     'unanswered:$callsUnAnswered,'
  //     'agentSummary: ${agentSummay().join(', ')}';
  //
  // Map toJson() => {
  //       'totalCalls': totalCalls,
  //       'below20s': callsAnsweredWithin20s,
  //       'oneminuteplus': callWaitingMoreThanOneMinute,
  //       'unanswered': callsUnAnswered,
  //       'agentSummary': agentSummay()
  //     };
}
