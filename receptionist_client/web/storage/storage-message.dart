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

part of storage;

abstract class Message {

  static const String className = '${libraryName}.Message';
  /**
   * Get a [MessageList] starting from [lastID] and downward of max size [limit].
   *
   * So, for instance, parameters {[lastID] : 12 [limit] : 10,} will fetch a
   * messageList starting from
   * messageID 12, downto (including) 3.
   *
   */
  static Future<List<Model.Message>> list({Model.MessageFilter filter : null}) {
    final Completer completer = new Completer<List<Model.Message>>();
    Service.Message.store.list(filter: filter).then((List<ORModel.Message> messages) {

      completer.complete(messages.map((ORModel.Message message) =>
          new Model.Message.fromMap(message.asMap)).toList());
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  /**
   *
   */
  static Future<Model.Message> get(int messageID) {
    const String context = '${className}.get';

    final Completer completer = new Completer<Model.Message>();

    debugStorage("Message not found in cache, loading from service.", context);
    Service.Message.store.get(messageID).then((ORModel.Message message) {
      completer.complete(new Model.Message.fromMap(message.asMap));
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}
