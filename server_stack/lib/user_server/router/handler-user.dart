part of userserver.router;

class User {
  static final Logger log = new Logger('$libraryName.User');

  static const String className = '${libraryName}.User';

  final Database.User _userStore;

  User(Database.User this._userStore);

  /**
   * HTTP Request handler for returning a single user resource.
   */
  Future<shelf.Response> get(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    return _userStore.get(userID).then((Model.User user) {
      return new shelf.Response.ok(JSON.encode(user));
    }).catchError((error, stackTrace) {
      if (error is Storage.NotFound) {
        return new shelf.Response.notFound(
            JSON.encode({'description': 'No user found with id:$userID'}));
      } else {
        log.severe('Failed to retrieve user with '
            'ID $userID', error, stackTrace);
        return new shelf.Response.internalServerError(
            body: '$error : $stackTrace');
      }
    });
  }

  /**
   * HTTP Request handler for returning a all user resources.
   */
  Future<shelf.Response> list(shelf.Request request) => _userStore
      .list()
      .then((Iterable<Model.User> users) =>
          new shelf.Response.ok(JSON.encode(users.toList(growable: false))));

  /**
   * HTTP Request handler for removing a single user resource.
   */
  Future<shelf.Response> remove(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    return _userStore.remove(userID).then((_) {
      Event.UserChange event = new Event.UserChange.deleted(userID);

      _notification.broadcastEvent(event);

      return new shelf.Response.ok('{}');
    }).catchError((error, stackTrace) {
      if (error is Storage.NotFound) {
        return new shelf.Response.notFound(
            JSON.encode({'description': 'No user found with id:$userID'}));
      } else {
        log.severe('Failed to retrieve user with '
            'ID $userID', error, stackTrace);
        return new shelf.Response.internalServerError(
            body: '$error : $stackTrace');
      }
    });
  }

  /**
   * HTTP Request handler for creating a single user resource.
   */
  Future<shelf.Response> create(shelf.Request request) {
    return request.readAsString().then((String content) {
      Model.User user = new Model.User.fromMap(JSON.decode(content));

      return _userStore.create(user).then((Model.User user) {
        Event.UserChange event = new Event.UserChange.created(user.ID);

        _notification.broadcastEvent(event);

        return new shelf.Response.ok(JSON.encode(user));
      });
    }).catchError((error, stackTrace) {
      if (error is FormatException) {
        log.warning('Failed to parse user in POST body', error, stackTrace);
        return new shelf.Response(400,
            body: 'Failed to parse user in POST body');
      }

      log.severe('Failed to extract content of request.', error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to extract content of request.');
    });
  }

  /**
   * HTTP Request handler for updating a single user resource.
   */
  Future<shelf.Response> update(shelf.Request request) {
    return request.readAsString().then((String content) {
      Model.User user = new Model.User.fromMap(JSON.decode(content));

      return _userStore.update(user).then((Model.User user) {
        Event.UserChange event = new Event.UserChange.updated(user.ID);

        _notification.broadcastEvent(event);

        return new shelf.Response.ok(JSON.encode(user));
      });
    }).catchError((error, stackTrace) {
      if (error is FormatException) {
        log.warning('Failed to parse user in POST body', error, stackTrace);
        return new shelf.Response(400,
            body: 'Failed to parse user in POST body');
      }

      log.severe('Failed to extract content of request.', error, stackTrace);
      return new shelf.Response.internalServerError(
          body: 'Failed to extract content of request.');
    });
  }

  /**
   * Returns all the groups associated with a user.
   */
  Future<shelf.Response> userGroups(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    return _userStore
        .userGroups(userID)
        .then((Iterable<Model.UserGroup> groups) {
      return new shelf.Response.ok(JSON.encode(groups.toList(growable: false)));
    });
  }

  /**
   * Response handler for joining a user in a group.
   */
  Future<shelf.Response> joinGroup(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));
    int groupID = int.parse(shelf_route.getPathParameter(request, 'gid'));

    return _userStore.joinGroup(userID, groupID).then((_) =>
      new shelf.Response.ok(JSON.encode(const {})));
  }

  /**
   * Response handler for leaving a user from a group.
   */
  Future<shelf.Response> leaveGroup(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));
    int groupID = int.parse(shelf_route.getPathParameter(request, 'gid'));

    return _userStore.leaveGroup(userID, groupID).then((_) =>
        new shelf.Response.ok(JSON.encode(const {})));
  }

  /**
   * Response handler for retrieving groups of a user.
   */
  Future<shelf.Response> userGroup(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    return _userStore.userGroups(userID).then(
        (Iterable<Model.UserGroup> groups) =>
            new shelf.Response.ok(JSON.encode(groups.toList(growable: false))));
  }

  /**
   * Response handler for retrieving identities of a user.
   */
  Future<shelf.Response> userIdentities(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    return _userStore.identities(userID).then(
        (Iterable<Model.UserIdentity> identities) => new shelf.Response.ok(
            JSON.encode(identities.toList(growable: false))));
  }

  /**
   * Response handler for adding an identity to a user.
   */
  Future<shelf.Response> addIdentity(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    return request
        .readAsString()
        .then(JSON.decode)
        .then(Model.UserIdentity.decode)
        .then((Model.UserIdentity identity) {
          identity.userId = userID;
          _userStore
            .addIdentity(identity)
            .then((_) => new shelf.Response.ok(JSON.encode(const {})));
    });
  }

  /**
   * Response handler for removing an identity from a user.
   */
  Future<shelf.Response> removeIdentity(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    return request
        .readAsString()
        .then(JSON.decode)
        .then(Model.UserIdentity.decode)
        .then((Model.UserIdentity identity) {
          identity.userId = userID;
          _userStore
            .removeIdentity(identity)
            .then((_) => new shelf.Response.ok(JSON.encode(const {})));
    });
  }

  /**
   * List every available group in the store.
   */
  Future<shelf.Response> groups(shelf.Request request) => _userStore
      .groups()
      .then((Iterable<Model.UserGroup> groups) =>
          new shelf.Response.ok(JSON.encode(groups.toList(growable: false))));
}
