library user.view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../lib/eventbus.dart';
import '../lib/logger.dart' as log;
import '../lib/model.dart';
import '../lib/request.dart' as request;
import '../lib/view_utilities.dart';
import '../notification.dart' as notify;

part 'components/user_groups.dart';
part 'components/user_identity.dart';

class UserView {
  static const String viewName = 'user';
  DivElement element;

  ButtonElement newUserButton, saveUserButton, removeUserButton;

  UListElement userList;
  UserGroupContainer groupContainer;
  IdentityContainer identityContainer;

  TextInputElement userName, userExtension, userSendFrom;

  int selectedUserId;
  bool isNewUser = false;

  UserView(DivElement this.element) {
    newUserButton = element.querySelector('#user-create');
    userList = element.querySelector('#user-list');

    saveUserButton = element.querySelector('#user-save');
    removeUserButton = element.querySelector('#user-delete');
    groupContainer = new UserGroupContainer(element.querySelector('#groups-table'));
    identityContainer = new IdentityContainer(element.querySelector('#user-identities'));

    userName = element.querySelector('#user-name');
    userExtension = element.querySelector('#user-extension');
    userSendFrom = element.querySelector('#user-sendfrom');

    refreshList();
    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
    });

    bus.on(UserAddedEvent).listen((UserAddedEvent event) {
      refreshList();
    });

    bus.on(UserRemovedEvent).listen((UserRemovedEvent event) {
      refreshList();
    });

    newUserButton.onClick.listen((_) => newUser());
    saveUserButton.onClick.listen((_) => saveChanges());
    removeUserButton.onClick.listen((_) => deleteUser());
  }

  Future refreshList() {
    return request.getUserList().then((List<User> users) {
      users.sort();
      renderUserList(users);
    }).catchError((error) {
      log.error('Failed to refreshing the list of receptions in reception window.');
    });
  }

  void renderUserList(List<User> users) {
    userList.children
      ..clear()
      ..addAll(users.map(makeUserNode));
  }

  LIElement makeUserNode(User user) {
    return new LIElement()
      ..text = user.name
      ..classes.add('clickable')
      ..dataset['userid'] = '${user.id}'
      ..onClick.listen((_) => activateUser(user.id));
  }

  void activateUser(int userId) {
    request.getUser(userId).then((User user) {
      isNewUser = false;
      selectedUserId = userId;

      userName.value = user.name;
      userExtension.value = user.extension;
      userSendFrom.value = user.sendFrom;

      highlightUserInList(userId);
      identityContainer.showIdentities(userId);
      return groupContainer.showUsersGroups(userId);
    }).catchError((error) {
      log.error('Failed to fetch user ${userId} got: "${error}"');
    });
  }

  void highlightUserInList(int id) {
    userList.children.forEach((LIElement li) => li.classes.toggle('highlightListItem', li.dataset['userid'] == '$id'));
  }

  void newUser() {
    isNewUser = true;

    userName.value = '';
    userExtension.value = '';
    userSendFrom.value = '';

    groupContainer.showNewUsersGroups();
    identityContainer.showNewUsersIdentities();
  }

  void saveChanges() {
    User user = new User()
      ..extension = userExtension.value
      ..name = userName.value
      ..sendFrom = userSendFrom.value;

    Future basicInformationRequest;
    if(isNewUser) {
      basicInformationRequest = request.createUser(JSON.encode(user))
        .then((Map user) {
          int userId = user['id'];
          selectedUserId = userId;
          isNewUser = false;
          bus.fire(new UserAddedEvent(userId));
          notify.info('Brugeren blev oprettet');
      }).catchError((error, stack) {
        log.error('Tried to create a new user from data: "${JSON.encode(user)}" but got: ${error} ${stack}');
        notify.error('Der skete en fejl i forbindelse med oprettelsen af brugeren. Fejl: ${error}');
      });
    } else {
      basicInformationRequest = request.updateUser(selectedUserId, JSON.encode(user))
          .then((_) {
        notify.info('Brugeren blev opdateret');
      }).catchError((error, stack) {
        log.error('Tried to update user "${selectedUserId}" from data: "${JSON.encode(user)}" but got: ${error} ${stack}');
        notify.error('Der skete en fejl i forbindelse med opdateringen af brugeren. Fejl: ${error}');
      });
    }

    basicInformationRequest
      .then((_) =>
        identityContainer.saveChanges(selectedUserId))
      .catchError((error, stack) {
          notify.error('Lageringen af brugerens identiteter gav en fejl. ${error}');
        })
      .then((_) =>
        groupContainer.saveChanges(selectedUserId)
      ).catchError((error) {
        notify.error('Lageringen af brugerens rettigheder gav en fejl.');
      });
  }

  void deleteUser() {
    if(!isNewUser && selectedUserId != null) {
      request.deleteUser(selectedUserId)
        .then((_) {
          bus.fire(new UserRemovedEvent(selectedUserId));
          selectedUserId = null;
          notify.info('Brugeren er slettet.');
        })
        .catchError((error) {
          notify.error('Der skete en fejl i forbindelse med sletningen af brugeren');
          log.error('Delete user failed with: ${error}');
        });
    }
  }
}
