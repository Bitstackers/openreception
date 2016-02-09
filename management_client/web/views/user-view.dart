library user.view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../lib/eventbus.dart';
import '../lib/logger.dart' as log;
import 'package:management_tool/controller.dart' as Controller;
import '../lib/view_utilities.dart';
import '../notification.dart' as notify;
import 'package:openreception_framework/model.dart' as ORModel;

part 'components/user_groups.dart';
part 'components/user_identity.dart';

class UserView {
  static const String viewName = 'user';
  DivElement element;
  final Controller.User _userController;

  ButtonElement newUserButton, saveUserButton, removeUserButton;

  UListElement userList;
  UserGroupContainer groupContainer;
  IdentityContainer identityContainer;

  TextInputElement userName, userExtension, userSendFrom;

  int selectedUserId;
  bool isNewUser = false;

  UserView(DivElement this.element, Controller.User this._userController) {
    newUserButton = element.querySelector('#user-create');
    userList = element.querySelector('#user-list');

    saveUserButton = element.querySelector('#user-save');
    removeUserButton = element.querySelector('#user-delete');
    groupContainer = new UserGroupContainer(element.querySelector('#groups-table'), _userController);
    identityContainer = new IdentityContainer(element.querySelector('#user-identities'), _userController);

    userName = element.querySelector('#user-name');
    userExtension = element.querySelector('#user-extension');
    userSendFrom = element.querySelector('#user-sendfrom');

    refreshList();
    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    bus.on(WindowChanged).listen((WindowChanged event) {
      element.classes.toggle('hidden', event.window != viewName);
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
    return _userController.list().then((Iterable<ORModel.User> users) {
      //users.sort();
      renderUserList(users);
    });
  }

  void renderUserList(Iterable<ORModel.User> users) {
    userList.children
      ..clear()
      ..addAll(users.map(makeUserNode));
  }

  LIElement makeUserNode(ORModel.User user) {
    return new LIElement()
      ..text = user.name
      ..classes.add('clickable')
      ..dataset['userid'] = '${user.ID}'
      ..onClick.listen((_) => activateUser(user.ID));
  }

  void activateUser(int userId) {
    _userController.get(userId).then((ORModel.User user) {
      isNewUser = false;
      selectedUserId = userId;

      userName.value = user.name;
      userExtension.value = user.peer;
      userSendFrom.value = user.address;

      highlightUserInList(userId);
      identityContainer.showIdentities(userId);
      return groupContainer.showUsersGroups(userId);
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
    ORModel.User user = new ORModel.User.empty()
      ..peer = userExtension.value
      ..name = userName.value
      ..address = userSendFrom.value;

    Future basicInformationRequest;
    if(isNewUser) {
      basicInformationRequest = _userController.create(user)
        .then((ORModel.User user) {
          selectedUserId = user.ID;
          isNewUser = false;
          bus.fire(new UserAddedEvent(user.ID));
          notify.info('Brugeren blev oprettet');
      }).catchError((error, stack) {
        log.error('Tried to create a new user from data: "${JSON.encode(user)}" but got: ${error} ${stack}');
        notify.error('Der skete en fejl i forbindelse med oprettelsen af brugeren. Fejl: ${error}');
      });
    } else {
      basicInformationRequest = _userController.update(user)
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
      _userController.remove(selectedUserId)
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
