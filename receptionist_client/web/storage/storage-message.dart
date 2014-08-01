/*                     This file is part of Bob
                   Copyright (C) 2014-, AdaHeads K/S

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

  static model.MessageList _messageCache = new model.MessageList();
  
  /**
   * Get a [MessageList] starting from [lastID] and downward of max size [limit].
   * 
   * So, for instance, parameters {[lastID] : 12 [limit] : 10,} will fetch a messageList starting from 
   * messageID 12, downto (including) 3.
   * 
   */
  static Future<model.MessageList> list({int lastID                 : model.Message.noID, 
                                         int limit                  : 100, 
                                         model.MessageFilter filter : null}) {
    const String context = '${className}.list';

    final Completer completer = new Completer<model.MessageList>();
    
    debugStorage("Message list not found in cache, loading from service.", context);
    Service.Message.list(lastID: lastID, limit: limit, filter: filter).then((model.MessageList messages) {
      completer.complete(messages);
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  /**
   * 
   */
  static Future<model.Message> get(int messageID) {
    const String context = '${className}.get';

    final Completer completer = new Completer<model.Message>();
    
    debugStorage("Message not found in cache, loading from service.", context);
    Service.Message.get(messageID).then((model.Message message) {
      completer.complete(message);
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }


  /**
   * Get the [MessageList] from cache.
   * TODO: implement.
   */
  static Future<model.MessageList> listCached({int lastID                 : model.Message.noID, 
                                               int maxRows                : 100, 
                                               model.MessageFilter filter : null}) {
    const String context = '${className}.list';

    final Completer completer = new Completer<model.MessageList>();
    
    if (_messageCache.contains(lastID)) {
      debugStorage("Loading message list from cache.", context);
      completer.complete( new model.MessageList.fromMessageMap(_messageCache.take(maxRows)));
    } else {
      debugStorage("Message list not found in cache, loading from service.", context);
      Service.Message.list().then((model.MessageList messages) {
        _messageCache.addAll(messages.values);
        _contactListCache[receptionID] = contactList;
        completer.complete(contactList);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

}
