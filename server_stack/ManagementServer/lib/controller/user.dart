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
  final Database db;

  UserController(Database this.db);

  void createUser(HttpRequest request) {
    const String context = '${libraryName}.createUser';

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
    const String context = '${libraryName}.deleteUser';
    final int userId = orf_http.pathParameter(request.uri, 'user');

    db.deleteUser(userId)
    .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
    .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getUser(HttpRequest request) {
    const String context = '${libraryName}.getUser';
    final int userId = orf_http.pathParameter(request.uri, 'user');

    db.getUser(userId).then((User user) {
      if(user == null) {
        return orf_http.notFound(request, {});
      } else {
        return orf_http.writeAndClose(request, userAsJson(user));
      }
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getUserList(HttpRequest request) {
    const String context = '${libraryName}.getUserList';

    db.getUserList().then((List<User> list) =>
        orf_http.writeAndClose(request, listUserAsJson(list)))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void updateUser(HttpRequest request) {
    const String context = '${libraryName}.updateUser';
    final int userId = orf_http.pathParameter(request.uri, 'user');

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
    const String context = '${libraryName}.getUserGroups';
    final int userId = orf_http.pathParameter(request.uri, 'user');

    db.getUserGroups(userId)
      .then((List<UserGroup> data) => orf_http.writeAndClose(request, userGroupAsJson(data)) )
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void joinUserGroups(HttpRequest request) {
    const String context = '${libraryName}.joinUserGroups';
    final int userId = orf_http.pathParameter(request.uri, 'user');
    final int groupId = orf_http.pathParameter(request.uri, 'group');

    db.joinUserGroup(userId, groupId).then((_) {
      orf_http.allOk(request);
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void leaveUserGroups(HttpRequest request) {
    const String context = '${libraryName}.leaveUserGroups';
    final int userId = orf_http.pathParameter(request.uri, 'user');
    final int groupId = orf_http.pathParameter(request.uri, 'group');

    db.leaveUserGroup(userId, groupId).then((_) {
      return orf_http.allOk(request);
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getGroupList(HttpRequest request) {
    const String context = '${libraryName}.getGroupList';

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
    const String context = '${libraryName}.getUserIdentityList';
    final int userId = orf_http.pathParameter(request.uri, 'user');

    db.getUserIdentityList(userId).then((List<UserIdentity> list) {
      return orf_http.writeAndClose(request, listUserIdentityAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void createUserIdentity(HttpRequest request) {
    const String context = '${libraryName}.createUserIdentity';
    final int userId = orf_http.pathParameter(request.uri, 'user');

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
    const String context = '${libraryName}.updateUserIdentity';
    final int userId = orf_http.pathParameter(request.uri, 'user');
    final String identityId = orf_http.pathParameterString(request.uri, 'identity');

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
    const String context = '${libraryName}.deleteUserIdentity';
    final int userId = orf_http.pathParameter(request.uri, 'user');
    final String identityId = orf_http.pathParameterString(request.uri, 'identity');

    db.deleteUserIdentity(userId, identityId)
      .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }
}
