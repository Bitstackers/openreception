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

class MessageQueue implements storage.MessageQueue {
  final Logger _log = new Logger('$libraryName.MessageQueue');
  final String path;

  Sequencer _sequencer;

  /**
   *
   */
  MessageQueue(String this.path) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync();
    }

    _sequencer = new Sequencer(path);
  }

  /// Returns the next available ID from the sequencer. Notice that every
  /// call to this function will increase the counter in the
  /// sequencer object.
  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  @override
  Future<model.MessageQueueEntry> enqueue(model.Message message) async {
    final int mqId = _nextId;

    final model.MessageQueueEntry queueEntry =
        new model.MessageQueueEntry.empty()
          ..id = mqId
          ..unhandledRecipients = message.recipients
          ..message = message;

    final File file = new File('$path/$mqId.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    file.writeAsStringSync(_jsonpp.convert(queueEntry));

    return queueEntry;
  }

  /**
   *
   */
  @override
  Future update(model.MessageQueueEntry queueEntry) async {
    final File file = new File('$path/${queueEntry.id}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    file.writeAsStringSync(_jsonpp.convert(queueEntry));

    return queueEntry;
  }

  /**
   *
   */
  @override
  Future remove(int mqid) async {
    final File file = new File('$path/$mqid.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    await file.delete();
  }

  /**
   *
   */
  @override
  Future<Iterable<model.MessageQueueEntry>> list() async => new Directory(path)
      .listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .map((FileSystemEntity fse) => model.MessageQueueEntry
          .decode(JSON.decode((fse as File).readAsStringSync())));
}
