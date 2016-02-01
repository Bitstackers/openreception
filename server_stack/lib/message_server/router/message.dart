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

part of openreception.message_server.router;

/**
 * Response templates.
 */
shelf.Response _authServerDown() =>
    new shelf.Response(502, body: 'Authentication server is not reachable');

shelf.Response _clientError(String reason) =>
    new shelf.Response(400, body: reason);

shelf.Response _ok(String reason) => new shelf.Response(200, body: reason);

shelf.Response _notFound(String reason) =>
    new shelf.Response(404, body: reason);

shelf.Response _serverError(String reason) =>
    new shelf.Response(500, body: reason);

abstract class Message {
  static final Logger log = new Logger('$libraryName.Message');

  static const String className = '${libraryName}.Message';

  /**
   * HTTP Request handler for returning a single message resource.
   */
  static Future<shelf.Response> get(shelf.Request request) async {
    final String midStr = shelf_route.getPathParameter(request, 'mid');
    int mid;

    try {
      mid = int.parse(midStr);
    } on FormatException {
      final msg = 'Bad message id :$midStr';
      log.warning(msg);

      _clientError(msg);
    }

    try {
      Model.Message message = await _messageStore.get(mid);

      return _ok(JSON.encode(message));
    } on Storage.NotFound {
      return _notFound('Not found: $mid');
    } catch (error, stackTrace) {
      final String msg = 'Failed to retrieve message with ID $mid';
      log.severe(msg, error, stackTrace);

      return _serverError(msg);
    }
  }

  /**
   * HTTP Request handler for updating a single message resource.
   */
  static Future<shelf.Response> update(shelf.Request request) async {
    Model.User user;

    /// User object fetching.
    try {
      user = await _authService.userOf(_tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return _authServerDown();
    }

    String content;
    Model.Message message;
    try {
      content = await request.readAsString();
      message = new Model.Message.fromMap(JSON.decode(content))
        ..senderId = user.id;
      if (message.ID == Model.Message.noID) {
        return _clientError('Refusing to update a non-existing message. '
            'set messageID or use the PUT method instead.');
      }
    } catch (error, stackTrace) {
      final msg = 'Failed to parse message in POST body. body:$content';
      log.severe(msg, error, stackTrace);

      return _clientError(msg);
    }

    Model.Message createdMessage = await _messageStore.update(message);

    _notification.broadcastEvent(
        new Event.MessageChange.updated(createdMessage.ID, user.ID));

    return _ok(JSON.encode(createdMessage));
  }

  /**
   * HTTP Request handler for removing a single message resource.
   */
  static Future<shelf.Response> remove(shelf.Request request) async {
    final int messageID =
        int.parse(shelf_route.getPathParameter(request, 'mid'));

    try {
      await _messageStore.remove(messageID);
    } on Storage.NotFound {
      return _notFound('$messageID');
    }

    return _ok('');
  }

  /**
   * Builds a list of previously stored messages, filtering by the
   * parameters passed in the [queryParameters] of the request.
   */
  static Future<shelf.Response> list(shelf.Request request) async {
    Model.MessageFilter filter = new Model.MessageFilter.empty();

    if (_filterFrom(request) != null) {
      try {
        Map map = JSON.decode(_filterFrom(request));
        filter = new Model.MessageFilter.fromMap(map);
      } catch (error, stackTrace) {
        log.warning('Bad filter', error, stackTrace);

        return _clientError('Bad filter');
      }
    }

    return await _messageStore
        .list(filter: filter)
        .then((Iterable<Model.Message> messages) =>
            _ok(JSON.encode(messages.toList())))
        .catchError((error, stackTrace) {
      log.severe(error, stackTrace);
      return _serverError(error.toString);
    });
  }

  /**
   * Enqueues a messages for dispathing via the transport layer specified in
   * the endpoints belonging to the message recipients.
   */
  static Future<shelf.Response> send(shelf.Request request) async {
    Model.User user;

    /// User object fetching.
    try {
      user = await _authService.userOf(_tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return _authServerDown();
    }

    String content;
    Model.Message message;
    try {
      content = await request.readAsString();
      message = new Model.Message.fromMap(JSON.decode(content))
        ..senderId = user.ID;

      if ([Model.Message.noID, null].contains(message.ID)) {
        return _clientError('Invalid message ID');
      }
    } catch (error, stackTrace) {
      final msg = 'Failed to parse message in POST body. body:$content';
      log.severe(msg, error, stackTrace);

      return _clientError(msg);
    }

    return await _messageStore
        .enqueue(message)
        .then((Model.MessageQueueItem queueItem) {
      _notification
          .broadcastEvent(new Event.MessageChange.updated(message.ID, user.ID));

      return _ok(JSON.encode(queueItem));
    });
  }

  /**
   * Persistently stores a messages. If the message already exists, the
   * message - and the it's contents - are replaced by the one passed by the client.
   */
  static Future<shelf.Response> create(shelf.Request request) async {
    Model.User user;

    /// User object fetching.
    try {
      user = await _authService.userOf(_tokenFrom(request));
    } catch (error, stackTrace) {
      final String msg = 'Failed to contact authserver';
      log.severe(msg, error, stackTrace);

      return _authServerDown();
    }

    String content;
    Model.Message message;
    try {
      content = await request.readAsString();
      message = new Model.Message.fromMap(JSON.decode(content))
        ..senderId = user.ID;

      if (message.ID != Model.Message.noID) {
        return _clientError('Refusing to re-create existing message. '
            'Remove messageID or use the POST method instead.');
      }
    } catch (error, stackTrace) {
      final msg = 'Failed to parse message in PUT body. body:$content';
      log.severe(msg, error, stackTrace);

      return _clientError(msg);
    }

    return await _messageStore
        .create(message)
        .then((Model.Message createdMessage) {
      _notification
          .broadcastEvent(new Event.MessageChange.created(message.ID, user.ID));

      return _ok(JSON.encode(createdMessage));
    });
  }
}
