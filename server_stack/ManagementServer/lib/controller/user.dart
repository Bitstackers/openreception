library userController;

import 'dart:io';
import 'dart:convert';

import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/user.dart';
import '../view/user_group.dart';
import '../view/user_identity.dart';

class UserController {
  Database db;

  UserController(Database this.db);

  void createUser(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createUser(data['name'], data['extension']))
    .then((int id) => writeAndCloseJson(request, userIdAsJson(id)))
    .catchError((error) {
      logger.error('create user failed: $error');
      Internal_Error(request);
    });
  }

  void deleteUser(HttpRequest request) {
    int userId = intPathParameter(request.uri, 'user');

    db.deleteContact(userId)
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error('deleteUser url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getUser(HttpRequest request) {
    int userId = intPathParameter(request.uri, 'user');

    db.getUser(userId).then((User user) {
      if(user == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, userAsJson(user));
      }
    }).catchError((error) {
      logger.error('get user Error: "$error"');
      Internal_Error(request);
    });
  }

  void getUserList(HttpRequest request) {
    db.getUserList().then((List<User> list) {
      return writeAndCloseJson(request, listUserAsJson(list));
    }).catchError((error) {
      logger.error('get user list Error: "$error"');
      Internal_Error(request);
    });
  }

  void updateUser(HttpRequest request) {
    int userId = intPathParameter(request.uri, 'user');
    extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updateUser(userId, data['name'], data['extension']))
      .then((int id) => writeAndCloseJson(request, userIdAsJson(id)))
      .catchError((error) {
        logger.error('updateUser url: "${request.uri}" gave error "${error}"');
        Internal_Error(request);
      });
  }

  void getUserGroups(HttpRequest request) {
    int userId = intPathParameter(request.uri, 'user');
    db.getUserGroups(userId)
      .then((List<UserGroup> data) => writeAndCloseJson(request, userGroupAsJson(data)) )
      .catchError((error) {
        logger.error('getUserGroups: url: "${request.uri}" gave error "${error}"');
	      Internal_Error(request);
      });
  }

  void joinUserGroups(HttpRequest request) {
    int userId = intPathParameter(request.uri, 'user');
    int groupId = intPathParameter(request.uri, 'group');

    db.joinUserGroup(userId, groupId).then((_) {
      writeAndCloseJson(request, JSON.encode({}));
    }).catchError((error) {
      logger.error('joinUserGroups: url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void leaveUserGroups(HttpRequest request) {
    int userId = intPathParameter(request.uri, 'user');
    int groupId = intPathParameter(request.uri, 'group');

    db.leaveUserGroup(userId, groupId).then((_) {
      writeAndCloseJson(request, JSON.encode({}));
    }).catchError((error) {
      logger.error('leaveUserGroups: url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getGroupList(HttpRequest request) {
    db.getGroupList()
      .then((List<UserGroup> data) => writeAndCloseJson(request, userGroupAsJson(data)) )
      .catchError((error) {
        logger.error('getGroupList: url: "${request.uri}" gave error "${error}"');
        Internal_Error(request);
      });
  }

  /**
   * Identity
   */
  void getUserIdentityList(HttpRequest request) {
    int userId = intPathParameter(request.uri, 'user');

    db.getUserIdentityList(userId).then((List<UserIdentity> list) {
      return writeAndCloseJson(request, listUserIdentityAsJson(list));
    }).catchError((error) {
      logger.error('getUserIdentityList Error: "$error"');
      Internal_Error(request);
    });
  }

  void createUserIdentity(HttpRequest request) {
    int userId = intPathParameter(request.uri, 'user');

    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createUserIdentity(userId, data['identity'], data['send_from']))
    .then((String identityId) => writeAndCloseJson(request, userIdentityIdAsJson(identityId)))
    .catchError((error) {
      logger.error('create UserIdentity url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void updateUserIdentity(HttpRequest request) {
    int userId = intPathParameter(request.uri, 'user');
    String identityId = PathParameter(request.uri, 'identity');

    extractContent(request)
    .then((String TEST) {
      logger.debug('TESTING $TEST');
      return TEST;
    })
    .then(JSON.decode)
    .then((Map data) => db.updateUserIdentity(userId, identityId, data['identity'], data['send_from'], data['user_id']))
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error('updateUserIdentity url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void deleteUserIdentity(HttpRequest request) {
    int userId = intPathParameter(request.uri, 'user');
    String identityId = PathParameter(request.uri, 'identity');

    db.deleteUserIdentity(userId, identityId)
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error('deleteUserIdentity url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }
}