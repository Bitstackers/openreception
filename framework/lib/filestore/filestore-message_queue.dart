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
  GitEngine _git;
  Sequencer _sequencer;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  String get _newUuid => _uuid.v4();

  /**
   *
   */
  MessageQueue({String this.path: 'json-data/message-queue'}) {
    if (!new Directory(path).existsSync()) {
      new Directory(path).createSync(recursive: true);
    }
    _git = new GitEngine(path);
    _git.init();
    _sequencer = new Sequencer(path);
  }

  Future<model.MessageQueueItem> save(model.MessageQueueItem queueItem) {
    throw new UnimplementedError();
  }

  Future archive(model.MessageQueueItem queueItem) {
    throw new UnimplementedError();
  }

  Future<Iterable<model.MessageQueueItem>> list(
      {int limit: 100, int maxTries: 10}) {
    throw new UnimplementedError();
  }
}
