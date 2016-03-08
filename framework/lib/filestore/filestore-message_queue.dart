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

class MessageQueue implements storage.MessageQueue {
  final Logger _log = new Logger('$libraryName.MessageQueue');
  final String path;
  final storage.Message _messageStore;
  Sequencer _sequencer;

  int get _nextId => _sequencer.nextInt();

  /**
   *
   */
  MessageQueue(this._messageStore,
      {String this.path: 'json-data/message_queue'}) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync(recursive: true);
    }

    _sequencer = new Sequencer(path);
  }

  /**
   *
   */
  Future enqueue(int mid) async {
    final int mqId = _nextId;

    final model.Message msg = await _messageStore.get(mid);
    final model.MessageQueueEntry queueEntry =
        new model.MessageQueueEntry.empty()
          ..id = mqId
          ..unhandledRecipients = msg.recipients
          ..message = msg;

    final File file = new File('$path/$mqId.json');

    if (file.existsSync()) {
      throw new storage.ClientError(
          'File already exists, please update instead');
    }

    file.writeAsStringSync(_jsonpp.convert(queueEntry));
  }

  /**
   *
   */
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
  Future remove(int mqid) async {
    final File file = new File('$path/${mqid}.json');

    if (!file.existsSync()) {
      throw new storage.NotFound();
    }

    await file.delete();
  }

  /**
   *
   */
  Future<Iterable<model.MessageQueueEntry>> list() async => new Directory(path)
      .listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .map((File fse) =>
          model.MessageQueueEntry.decode(JSON.decode(fse.readAsStringSync())));
}
