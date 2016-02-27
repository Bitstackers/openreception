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

part of openreception.filestore;

class Calendar implements storage.Calendar {
  final Logger _log = new Logger('$libraryName.Calendar');
  final String path;
  GitEngine _git;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  String get _newUuid => _uuid.v4();

  /**
   *
   */
  Calendar({String this.path: 'json-data/calendar'}) {
    _git = new GitEngine(path);
    _git.init();
  }

  /**
   *
   */
  Future<Iterable<model.CalendarEntryChange>> changes(entryId) async {
    Iterable<Change> gitChanges =
        await _git.changes(new File('$path/${entryId}.json'));

    return gitChanges.map((change) => new model.CalendarEntryChange()
      ..changedAt = change.changeTime
      ..userUuid = change.author);
  }

  /**
   *
   */
  Future<model.CalendarEntry> create(
      model.CalendarEntry entry, model.User user) async {
    entry.uuid = _newUuid;
    final File file = new File('$path/${entry.uuid}.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(entry));

    await _git.add(file, 'Added ${entry.uuid}', _authorString(user));

    return entry;
  }

  /**
   *
   */
  Future<model.CalendarEntry> get(entryId, {bool deleted: false}) async {
    final File file = new File('$path/${entryId}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound('No file with name ${entryId}');
    }

    try {
      final model.CalendarEntry menu =
          model.CalendarEntry.decode(JSON.decode(file.readAsStringSync()));
      return menu;
    } catch (e) {
      throw e;
    }
  }

  /**
   *
   */
  Future<model.CalendarEntryChange> latestChange(entryId) async =>
      (await changes(entryId)).first;

  /**
   *
   */
  Future<Iterable<model.CalendarEntry>> list(model.Owner owner,
          {bool deleted: false}) async =>
      (await _list()).where((entry) => entry.owner == owner);
  /**
   *
   */
  Future<Iterable<model.CalendarEntry>> _list() async => new Directory(path)
      .listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .map((File fse) =>
          model.CalendarEntry.decode(JSON.decode(fse.readAsStringSync())));

  /**
   * Trashes the [Model.CalendarEntry] associated with [entryId] in the
   * database, but keeps the object (in a hidden state) in the database.
   * The action is logged to be performed by user with ID [userId].
   */
  Future remove(entryId, model.User user) async {
    final File file = new File('$path/${entryId}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    await _git.remove(file, 'Removed $entryId', _authorString(user));
  }

  /**
   *
   */
  Future<model.CalendarEntry> update(
      model.CalendarEntry entry, model.User user) async {
    final File file = new File('$path/${entry.uuid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    /// Set the user
    if (user == null) {
      user = _systemUser;
    }

    file.writeAsStringSync(_jsonpp.convert(entry));

    await _git._commit('Updated ${entry.uuid}', _authorString(user));

    return entry;
  }
}
