library management_tool.page.user;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:route_hierarchical/client.dart';

import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/view.dart' as view;
import 'package:openreception.framework/model.dart' as model;

const String _libraryName = 'management_tool.page.user';

/**
 *
 */
class UserPage {
  final Logger _log = new Logger('$_libraryName.UserPage');

  final DivElement element = new DivElement()
    ..id = "user-page"
    ..hidden = true
    ..classes.addAll(['page']);

  final controller.User _userController;
  final Router _router;

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
  UserPage(this._userController, this._router) {
    _setupRouter();
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

    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _createButton.onClick.listen((_) => _router.gotoUrl('/user/create'));

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
      ..sort((model.UserReference userA, model.UserReference userB) =>
          userA.name.toLowerCase().compareTo(userB.name.toLowerCase()));

    renderUserList(users);
  }

  /**
   *
   */
  void renderUserList(Iterable<model.UserReference> users) {
    _userList.children
      ..clear()
      ..addAll(users.map(_makeUserNode));
  }

  /**
   *
   */
  LIElement _makeUserNode(model.UserReference user) {
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
  void _createUser(RouteEvent e) {
    element.hidden = false;
    _userView.user = new model.User.empty()..id = model.User.noId;
    highlightUserInList(model.User.noId);
  }

  /**
   *
   */
  Future activate(RouteEvent e) async {
    element.hidden = false;
    await _refreshList();
  }

  /**
   *
   */
  void deactivate(RouteEvent e) {
    element.hidden = true;
  }

  /**
   *
   */
  Future activateEdit(RouteEvent e) async {
    final int uid = int.parse(e.parameters['uid']);
    element.hidden = false;
    await _activateUser(uid);
  }

  /**
   *
   */
  void _setupRouter() {
    print('setting up user router');
    _router.root
      ..addRoute(
          name: 'user',
          enter: activate,
          path: '/user',
          leave: deactivate,
          mount: (router) => router
            ..addRoute(name: 'create', path: '/create', enter: _createUser)
            ..addRoute(
                name: 'edit',
                path: '/edit',
                mount: (router) => router
                  ..addRoute(name: 'id', path: '/:uid', enter: activateEdit)));
  }
}
