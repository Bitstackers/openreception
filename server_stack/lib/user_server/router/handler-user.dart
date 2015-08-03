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
  Future<shelf.Response> list(shelf.Request request)  =>
      _userStore.list().then((Iterable<Model.User> users) =>
          new shelf.Response.ok(JSON.encode(users.toList(growable: false))));

  /**
   * HTTP Request handler for removing a single user resource.
   */
  Future<shelf.Response> remove(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    return _userStore.remove(userID).then((_) {
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

      return _userStore.update(user).then((Model.User user) {
        Event.UserChange event =  new Event.UserChange.created(user.ID);

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
        Event.UserChange event =  new Event.UserChange.created(user.ID);

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

    return _userStore.userGroups(userID).then((Iterable<Model.UserGroup> groups) {
      return new shelf.Response.ok(JSON.encode(groups.toList(growable: false)));
   });
  }

  /**
   *
   */
  Future<shelf.Response> joinGroup(shelf.Request request) =>
      new Future.error(new UnimplementedError());


  /**
   *
   */
  Future<shelf.Response> leaveGroup(shelf.Request request) =>
      new Future.error(new UnimplementedError());


  /**
   *
   */
  Future<shelf.Response> userGroup(shelf.Request request) {
    int userID = int.parse(shelf_route.getPathParameter(request, 'uid'));

    return _userStore.userGroups(userID).then((Iterable<Model.UserGroup> groups) =>
        new shelf.Response.ok(JSON.encode(groups.toList(growable: false))));
  }


  /**
   *
   */
  Future<shelf.Response> userIdentities(shelf.Request request) =>
      new Future.error(new UnimplementedError());


  /**
   *
   */
  Future<shelf.Response> addIdentity(shelf.Request request) =>
      new Future.error(new UnimplementedError());


  /**
   *
   */
  Future<shelf.Response> removeIdentity(shelf.Request request) =>
      new Future.error(new UnimplementedError());


  /**
   *
   */
  Future<shelf.Response> userIndentity(shelf.Request request) =>
      new Future.error(new UnimplementedError());

  /**
   * List every available group in the store.
   */
  Future<shelf.Response> groups(shelf.Request request) =>
    _userStore.groups().then((Iterable<Model.UserGroup> groups) =>
        new shelf.Response.ok(JSON.encode(groups.toList(growable: false))));

}
