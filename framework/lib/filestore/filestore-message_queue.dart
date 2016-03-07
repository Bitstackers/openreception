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
  Sequencer _sequencer;

  int get _nextInt => _sequencer.nextInt();

  /**
   *
   */
  MessageQueue({String this.path: 'json-data/message_queue'}) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync(recursive: true);
    }

    _sequencer = new Sequencer(path);
  }

  Future<model.MessageQueueItem> save(model.MessageQueueItem queueItem) {
    throw new UnimplementedError();
  }

  Future archive(model.MessageQueueItem queueItem) {
    throw new UnimplementedError();
  }

  /**
   *
   */
  Future enqueue(int mid, model.User modifier) {}

  /**
   *
   */
  Future update(model.MessageQueueItem queueItem) {}

  /**
   *
   */
  Future remove(int mqid) {}

  /**
   *
   */
  Future<Iterable<model.MessageQueueItem>> list() {}
}
