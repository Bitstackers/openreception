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

  static Model.MessageList _messageCache = new Model.MessageList();

  /**
   * Get a [MessageList] starting from [lastID] and downward of max size [limit].
   *
   * So, for instance, parameters {[lastID] : 12 [limit] : 10,} will fetch a messageList starting from
   * messageID 12, downto (including) 3.
   *
   */
  static Future<List<Model.Message>> list({int lastID                 : Model.Message.noID,
                                         int limit                  : 100,
                                         Model.MessageFilter filter : null}) {
    const String context = '${className}.list';

    final Completer completer = new Completer<List<Model.Message>>();

    /// Note: the correct way of sending these parameters would probably be to
    ///  copy the object and, update the copy and send it.
    filter.upperMessageID = lastID;
    filter.limitCount = limit;

    debugStorage("Message list not found in cache, loading from service.", context);
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


  /**
   * Get the [MessageList] from cache.
   * TODO: implement.
   */
  static Future<Model.MessageList> listCached({int lastID                 : Model.Message.noID,
                                               int maxRows                : 100,
                                               Model.MessageFilter filter : null}) {
    const String context = '${className}.list';

    final Completer completer = new Completer<Model.MessageList>();

    if (_messageCache.contains(lastID)) {
      debugStorage("Loading message list from cache.", context);
      completer.complete( new Model.MessageList.fromMessageMap(_messageCache.take(maxRows)));
    } else {
      throw new StateError('Not implemeted!');
      debugStorage("Message list not found in cache, loading from service.", context);
      Service.Message.store.list().then((List<Model.Message> messages) {
        /*
        _messageCache.addAll(messages.values);
        _contactListCache[receptionID] = contactList;
        completer.complete(contactList); */
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

}
