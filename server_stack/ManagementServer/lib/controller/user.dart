library userController;

import 'dart:io';
import 'dart:convert';

import '../database.dart';
import '../model.dart';
import '../view/user.dart';
import '../view/user_group.dart';
import '../view/user_identity.dart';
import 'package:OpenReceptionFramework/common.dart' as orf;
import 'package:OpenReceptionFramework/httpserver.dart' as orf_http;

const libraryName = 'userController';

class UserController {
  Database db;

  UserController(Database this.db);

  void createUser(HttpRequest request) {
    const context = '${libraryName}.createUser';

    orf_http.extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createUser(data['name'], data['extension'], data['send_from']))
    .then((int id) => orf_http.writeAndClose(request, userIdAsJson(id)))
    .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void deleteUser(HttpRequest request) {
    const context = '${libraryName}.deleteUser';
    int userId = orf_http.pathParameter(request.uri, 'user');

    db.deleteUser(userId)
    .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
    .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getUser(HttpRequest request) {
    const context = '${libraryName}.getUser';
    int userId = orf_http.pathParameter(request.uri, 'user');

    db.getUser(userId).then((User user) {
      if(user == null) {
        request.response.statusCode = 404;
        return orf_http.writeAndClose(request, JSON.encode({}));
      } else {
        return orf_http.writeAndClose(request, userAsJson(user));
      }
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getUserList(HttpRequest request) {
    const context = '${libraryName}.getUserList';

    db.getUserList().then((List<User> list) {
      return orf_http.writeAndClose(request, listUserAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updateUser(HttpRequest request) {
    const context = '${libraryName}.updateUser';
    int userId = orf_http.pathParameter(request.uri, 'user');

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updateUser(userId, data['name'], data['extension'], data['send_from']))
      .then((int id) => orf_http.writeAndClose(request, userIdAsJson(id)))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void getUserGroups(HttpRequest request) {
    const context = '${libraryName}.getUserGroups';
    int userId = orf_http.pathParameter(request.uri, 'user');

    db.getUserGroups(userId)
      .then((List<UserGroup> data) => orf_http.writeAndClose(request, userGroupAsJson(data)) )
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void joinUserGroups(HttpRequest request) {
    const context = '${libraryName}.joinUserGroups';
    int userId = orf_http.pathParameter(request.uri, 'user');
    int groupId = orf_http.pathParameter(request.uri, 'group');

    db.joinUserGroup(userId, groupId).then((_) {
      orf_http.writeAndClose(request, JSON.encode({}));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void leaveUserGroups(HttpRequest request) {
    const context = '${libraryName}.leaveUserGroups';
    int userId = orf_http.pathParameter(request.uri, 'user');
    int groupId = orf_http.pathParameter(request.uri, 'group');

    db.leaveUserGroup(userId, groupId).then((_) {
      orf_http.writeAndClose(request, JSON.encode({}));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getGroupList(HttpRequest request) {
    const context = '${libraryName}.getGroupList';

    db.getGroupList()
      .then((List<UserGroup> data) => orf_http.writeAndClose(request, userGroupAsJson(data)) )
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  /**
   * Identity
   */
  void getUserIdentityList(HttpRequest request) {
    const context = '${libraryName}.getUserIdentityList';
    int userId = orf_http.pathParameter(request.uri, 'user');

    db.getUserIdentityList(userId).then((List<UserIdentity> list) {
      return orf_http.writeAndClose(request, listUserIdentityAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void createUserIdentity(HttpRequest request) {
    const context = '${libraryName}.createUserIdentity';
    int userId = orf_http.pathParameter(request.uri, 'user');

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.createUserIdentity(userId, data['identity']))
      .then((String identityId) => orf_http.writeAndClose(request, userIdentityIdAsJson(identityId)))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void updateUserIdentity(HttpRequest request) {
    const context = '${libraryName}.updateUserIdentity';
    int userId = orf_http.pathParameter(request.uri, 'user');
    String identityId = orf_http.pathParameterString(request.uri, 'identity');

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updateUserIdentity(userId, identityId, data['identity'], data['user_id']))
      .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void deleteUserIdentity(HttpRequest request) {
    const context = '${libraryName}.deleteUserIdentity';
    int userId = orf_http.pathParameter(request.uri, 'user');
    String identityId = orf_http.pathParameterString(request.uri, 'identity');

    db.deleteUserIdentity(userId, identityId)
      .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }
}
