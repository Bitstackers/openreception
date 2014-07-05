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

class UserView {
  String viewName = 'user';
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

    bus.on(Invalidate.userAdded).listen((Map event) {
      refreshList();
    });

    bus.on(Invalidate.userRemoved).listen((Map event) {
      refreshList();
    });

    newUserButton.onClick.listen((_) => newUser());
    saveUserButton.onClick.listen((_) => saveChanges());
    removeUserButton.onClick.listen((_) => deleteUser());
  }

  Future refreshList() {
    return request.getUserList().then((List<User> users) {
      users.sort((a, b) => a.name.compareTo(b.name));
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
          bus.fire(Invalidate.userAdded, user);
      });
    } else {
      basicInformationRequest = request.updateUser(selectedUserId, JSON.encode(user));
    }

    basicInformationRequest
      .then((_) =>
        identityContainer.saveChanges(selectedUserId))
      .catchError((error) {
          notify.error('Lageringen af brugerens identiteter gav en fejl.');
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
        bus.fire(Invalidate.userRemoved, {'id': selectedUserId});
          selectedUserId = null;
        })
        .catchError((error) {
          notify.error('Der skete en fejl i forbindelse med sletningen af brugeren');
          log.error('Delete user failed with: ${error}');
        });
    }
  }
}

class IdentityContainer {
  UListElement _ul;

  List<UserIdentity> _identities;

  IdentityContainer(UListElement this._ul);

  Future showIdentities(int userId) {
    return request.getUserIdentities(userId).then((List<UserIdentity> identities) {
      populateUL(identities);
    });
  }

  void populateUL(List<UserIdentity> identities) {
    InputElement newItem = _makeInputForNewItem();

    this._identities = identities;
    _ul.children
      ..clear()
      ..addAll(identities.map(_makeIdentityNode))
      ..add(new LIElement()..children.add(newItem));
  }

  InputElement _makeInputForNewItem() {
    InputElement newItem = new InputElement(type: 'text');
    newItem
      ..placeholder = 'Tilføj ny...'
      ..onKeyPress.listen((KeyboardEvent event) {
        KeyEvent key = new KeyEvent.wrap(event);
        if (key.keyCode == Keys.ENTER) {
          String item = newItem.value;
          newItem.value = '';

          LIElement li = _makeIdentityNode(new UserIdentity()..identity = item);
          int index = _ul.children.length - 1;
          _ul.children.insert(index, li);
        } else if (key.keyCode == Keys.ESCAPE) {
          newItem.value = '';
        }
      });
    return newItem;
  }

  void showNewUsersIdentities() {
    populateUL([]);
  }

  LIElement _makeIdentityNode(UserIdentity identity) {
    LIElement li = new LIElement();

    SpanElement content = new SpanElement()
      ..text = identity.identity;
    InputElement editBox = new InputElement(type: 'text');

    editableSpan(content, editBox);

    li.children.addAll([content, editBox]);
    return li;
  }

  Future saveChanges(int userId) {
    List<String> foundIdentities = [];

    for(LIElement item in _ul.children) {
      SpanElement span = item.children.firstWhere((i) => i is SpanElement, orElse: () => null);
      if(span != null) {
        String context = span.text;
        foundIdentities.add(context);
      }
    }

    List<Future> worklist = new List<Future>();

    //Inserts
    for(String identity in foundIdentities) {
      if(!_identities.any((UserIdentity i) => i.identity == identity)) {
        //Insert Identity
        Map data = {'identity': identity};
        worklist.add(request.createUserIdentity(userId, JSON.encode(data)));
      }
    }

    //Deletes
    for(UserIdentity identity in _identities) {
      if(!foundIdentities.any((String i) => i == identity.identity)) {
        //Delete Identity
        worklist.add(request.deleteUserIdentity(userId, identity.identity));
      }
    }
    return Future.wait(worklist);
  }
}

class UserGroupContainer {
  TableElement _table;

  List<CheckboxInputElement> _checkboxs = [];
  List<UserGroup> _groupList = [], _userGroupList = [];

  UserGroupContainer(TableElement this._table) {
    refreshGroupList();
  }

  void refreshGroupList() {
    request.getGroupList().then((List<UserGroup> groups) {
      groups.sort((a, b) => a.name.compareTo(b.name));
      _groupList = groups;
      _renderBaseList();
    });
  }

  void _renderBaseList() {
    _checkboxs.clear();

    _table.children
      ..clear()
      ..addAll(_groupList.map(_makeGroupRow));
  }

  TableRowElement _makeGroupRow(UserGroup group) {
    TableRowElement row = new TableRowElement();

    CheckboxInputElement checkbox = new CheckboxInputElement()
      ..id = 'grp_${group.id}'
      ..dataset['id'] = group.id.toString();
    _checkboxs.add(checkbox);

    TableCellElement checkCell = new TableCellElement()
      ..children.add(checkbox);

    TableCellElement labelCell = new TableCellElement()
      ..children.add(new LabelElement()
        ..htmlFor = 'grp_${group.id}'
        ..text = group.name);

    return row
      ..children.addAll([checkCell, labelCell]);
  }

  Future showUsersGroups(int userId) {
    return request.getUsersGroup(userId).then((List<UserGroup> groups) {
      _updateCheckBoxesWithUserGroup(groups);
    });
  }

  void _updateCheckBoxesWithUserGroup(List<UserGroup> groups) {
    _userGroupList = groups;
    for(CheckboxInputElement checkbox in _checkboxs) {
      checkbox.checked = groups.any((UserGroup userGroup) => userGroup.id == int.parse(checkbox.dataset['id']));
    }
  }

  void showNewUsersGroups() {
    _updateCheckBoxesWithUserGroup([]);
  }

  Future saveChanges(int userId) {
    List<int> inserts = [], removes = [];
    List<Future> worklist = [];

    for(CheckboxInputElement item in _checkboxs) {
      int id = int.parse(item.dataset['id']);
      bool userIsAMember = _userGroupList.any((g) => g.id == id);

      if(item.checked && !userIsAMember) {
        worklist.add(request.joinUserGroup(userId, id));

      } else if(!item.checked && userIsAMember) {
        worklist.add(request.leaveUserGroup(userId, id));
      }
    }
    return Future.wait(worklist);
  }
}
