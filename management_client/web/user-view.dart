library user_view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'lib/eventbus.dart';
import 'lib/logger.dart' as log;
import 'lib/model.dart';
import 'lib/request.dart' as request;
import 'lib/view_utilities.dart';
import 'notification.dart' as notify;

class UserView {
  String viewName = 'user';
  DivElement element;

  ButtonElement newUserButton, saveUserButton;

  UListElement userList;
  UserGroupContainer groupContainer;
  IdentityContainer identityContainer;

  TextInputElement userName, userExtension, userSendFrom;

  int selectedUserId;

  UserView(DivElement this.element) {
    newUserButton = element.querySelector('#user-create');
    userList = element.querySelector('#user-list');

    saveUserButton = element.querySelector('#user-save');
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

    newUserButton.onClick.listen((_) {
      //TODO
    });

    saveUserButton.onClick.listen((_) {
      saveChanges();
    });
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

  void saveChanges() {
    User user = new User()
      ..extension = userExtension.value
      ..name = userName.value
      ..sendFrom = userSendFrom.value;

    request.updateUser(selectedUserId, JSON.encode(user));

    //Save username, Extension, sendFrom
    identityContainer.saveChanges(selectedUserId).catchError((error) {
      notify.error('Lageringen af brugerens identiteter gav en fejl.');
    });

    groupContainer.saveChanges(selectedUserId).catchError((error) {
      notify.error('Lageringen af brugerens rettigheder gav en fejl.');
    });
  }

}

class IdentityContainer {
  UListElement ul;

  List<UserIdentity> identities;

  IdentityContainer(UListElement this.ul);

  Future showIdentities(int userId) {
    InputElement newItem = new InputElement(type: 'text');
    newItem
        ..placeholder = 'Tilføj ny...'
        ..onKeyPress.listen((KeyboardEvent event) {
          KeyEvent key = new KeyEvent.wrap(event);
          if (key.keyCode == Keys.ENTER) {
            String item = newItem.value;
            newItem.value = '';

            LIElement li = makeIdentityNode(new UserIdentity()..identity = item);
            int index = ul.children.length - 1;
            ul.children.insert(index, li);
          } else if (key.keyCode == Keys.ESCAPE) {
            newItem.value = '';
          }
        });

    return request.getUserIdentities(userId).then((List<UserIdentity> identities) {
      this.identities = identities;
      ul.children
        ..clear()
        ..addAll(identities.map(makeIdentityNode))
        ..add(new LIElement()..children.add(newItem));
    });
  }

  LIElement makeIdentityNode(UserIdentity identity) {
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

    for(LIElement item in ul.children) {
      SpanElement span = item.children.firstWhere((i) => i is SpanElement, orElse: () => null);
      if(span != null) {
        String context = span.text;
        foundIdentities.add(context);
      }
    }

    List<Future> worklist = new List<Future>();

    //Inserts
    for(String identity in foundIdentities) {
      if(!identities.any((UserIdentity i) => i.identity == identity)) {
        //Insert Identity
        Map data = {'identity': identity};
        worklist.add(request.createUserIdentity(userId, JSON.encode(data)));
      }
    }

    //Deletes
    for(UserIdentity identity in identities) {
      if(!foundIdentities.any((String i) => i == identity.identity)) {
        //Delete Identity
        worklist.add(request.deleteUserIdentity(userId, identity.identity));
      }
    }
    return Future.wait(worklist);
  }
}

class UserGroupContainer {
  TableElement table;

  List<CheckboxInputElement> checkboxs = [];
  List<UserGroup> groupList = [], userGroupList = [];

  UserGroupContainer(TableElement this.table) {
    refreshGroupList();
  }

  void refreshGroupList() {
    request.getGroupList().then((List<UserGroup> groups) {
      groups.sort((a, b) => a.name.compareTo(b.name));
      groupList = groups;
      renderBaseList();
    });
  }

  void renderBaseList() {
    checkboxs.clear();

    table.children
      ..clear()
      ..addAll(groupList.map(makeGroupRow));
  }

  TableRowElement makeGroupRow(UserGroup group) {
    TableRowElement row = new TableRowElement();

    CheckboxInputElement checkbox = new CheckboxInputElement()
      ..id = 'grp_${group.id}'
      ..dataset['id'] = group.id.toString();
    checkboxs.add(checkbox);

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
      userGroupList = groups;
      for(CheckboxInputElement checkbox in checkboxs) {
        checkbox.checked = groups.any((UserGroup userGroup) => userGroup.id == int.parse(checkbox.dataset['id']));
      }
    });
  }

  Future saveChanges(int userId) {
    List<int> inserts = [], removes = [];
    List<Future> worklist = [];

    for(CheckboxInputElement item in checkboxs) {
      int id = int.parse(item.dataset['id']);
      bool userIsAMember = userGroupList.any((g) => g.id == id);

      if(item.checked && !userIsAMember) {
        worklist.add(request.joinUserGroup(userId, id));

      } else if(!item.checked && userIsAMember) {
        worklist.add(request.leaveUserGroup(userId, id));
      }
    }
    return Future.wait(worklist);
  }
}
