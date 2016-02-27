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

class Message implements storage.Message {
  final Logger _log = new Logger('$libraryName.Organization');
  final String path;
  GitEngine _git;

  Future get initialized => _git.initialized;
  Future get ready => _git.whenReady;

  String get _newUuid => _uuid.v4();
  /**
   *
   */
  Message({String this.path: 'json-data/message'}) {
    _git = new GitEngine(path);
    _git.init();
  }

  Future enqueue(model.Message message) {
    throw new UnimplementedError();
  }

  Future<model.Message> get(int messageID) {
    throw new UnimplementedError();
  }

  Future<Iterable<model.Message>> list({model.MessageFilter filter}) {
    throw new UnimplementedError();
  }

  Future<model.Message> create(model.Message message) {
    throw new UnimplementedError();
  }

  Future<model.Message> update(model.Message message) {
    throw new UnimplementedError();
  }

  Future remove(int messageId) {
    throw new UnimplementedError();
  }
}
