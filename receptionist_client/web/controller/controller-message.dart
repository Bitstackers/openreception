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

part of controller;

class Message {
  final ORService.RESTMessageStore _store;

  /**
   * Constructor.
   */
  Message(this._store);

  /**
   * Saves a [ORModel.Message] object.
   */
  Future<ORModel.Message> save(ORModel.Message message) =>
    this._store.save(message);

  /**
   * Enqueues a [ORModel.Message] object.
   */
  Future<ORModel.Message> enqueue(ORModel.Message message) =>
    this._store.enqueue(message);

  /**
   *
   */
  Future<Iterable<ORModel.Message>> list() => this._store.list();

  /**
   *
   */
  Future<ORModel.Message> get(int messageID) => this._store.get(messageID);
}
