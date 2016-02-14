library management_tool.page.user;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/eventbus.dart';
import 'package:management_tool/view.dart' as view;
import 'package:openreception_framework/model.dart' as model;

const String _libraryName = 'management_tool.page.user';

/**
 *
 */
class UserPage {
  static const String _viewName = 'user';
  final Logger _log = new Logger('$_libraryName.UserPage');

  final DivElement element = new DivElement()
    ..id = "user-page"
    ..hidden = true
    ..classes.addAll(['page']);

  final controller.User _userController;
  view.User _userView;

  final ButtonElement _createButton = new ButtonElement()
    ..text = 'Opret'
    ..classes.add('create');

  final UListElement _userList = new UListElement()
    ..id = 'user-list'
    ..classes.add('zebra-even');

  /// Extracts the uid of the currently selected user.
  int get selectedUserId => _userView.userId;

  /**
   *
   */
  UserPage(this._userController) {
    _userView = new view.User(_userController);

    element.children = [
      (new DivElement()
        ..id = "user-listing"
        ..children = [
          new DivElement()
            ..id = "user-controlbar"
            ..classes.add('basic3controls')
            ..children = [_createButton],
          _userList,
        ]),
      _userView.element
    ];

    _refreshList();
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    bus.on(WindowChanged).listen((WindowChanged event) {
      print(event.window != _viewName);
      element.hidden = event.window != _viewName;
      element.classes.toggle('hidden', event.window != _viewName);
    });

    _createButton.onClick.listen((_) => _createUser());

    _userView.changes.listen((view.UserChange uc) async {
      await _refreshList();
      if (uc.type == view.Change.deleted) {} else if (uc.type ==
          view.Change.updated) {
        await _activateUser(uc.user.id);
      } else if (uc.type == view.Change.created) {
        await _activateUser(uc.user.id);
      }
    });
  }

  /**
   *
   */
  Future _refreshList() async {
    final users = (await _userController.list()).toList()
      ..sort((model.User userA, model.User userB) =>
          userA.name.toLowerCase().compareTo(userB.name.toLowerCase()));

    renderUserList(users);
  }

  /**
   *
   */
  void renderUserList(Iterable<model.User> users) {
    _userList.children
      ..clear()
      ..addAll(users.map(_makeUserNode));
  }

  /**
   *
   */
  LIElement _makeUserNode(model.User user) {
    return new LIElement()
      ..text = user.name
      ..classes.add('clickable')
      ..dataset['userid'] = '${user.id}'
      ..onClick.listen((_) => _activateUser(user.id));
  }

  /**
   *
   */
  Future _activateUser(int userId) async {
    _log.finest('Activating user $userId');
    highlightUserInList(userId);
    _userView.user = await _userController.get(userId);
    highlightUserInList(_userView.user.id);
  }

  /**
   *
   */
  void highlightUserInList(int id) {
    _userList.children.forEach((LIElement li) =>
        li.classes.toggle('highlightListItem', li.dataset['userid'] == '$id'));
  }

  /**
   *
   */
  void _createUser() {
    _userView.user = new model.User.empty()..id = model.User.noID;
    highlightUserInList(model.User.noID);
  }
}
