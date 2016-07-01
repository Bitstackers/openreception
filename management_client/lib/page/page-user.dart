library management_tool.page.user;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:management_tool/configuration.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/view.dart' as view;
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/model.dart' as model;
import 'package:route_hierarchical/client.dart';

const String _libraryName = 'management_tool.page.user';

/**
 *
 */
class User {
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
  User(this._userController, controller.PeerAccount peerAccountController,
      Stream<event.UserChange> userChanges, this._router) {
    _setupRouter();
    _userView = new view.User(_userController, peerAccountController);

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

    _observers(userChanges);
  }

  /**
   * Observers.
   */
  void _observers(Stream<event.UserChange> userChanges) {
    _createButton.onClick.listen((_) => _router.go('user.create', {}));

    userChanges.listen((event.UserChange e) async {
      if (!this.element.hidden) {
        /// Always refresh the userlist
        await _refreshList();

        /// This is the currently selected organization
        if (e.uid == _userView.user.id) {
          if (e.deleted) {
            _userView.clear();
            _userView.hidden = true;

            _router.go('user.edit.id', {'uid': e.uid});
          } else if (e.updated) {
            _router.go('user.edit.id', {'uid': e.uid});
          }
        } else if (e.created && e.modifierUid == config.user.id) {
          _router.go('user.edit.id', {'uid': e.uid});
        }
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
      ..onClick.listen((_) => _router.go('user.edit.id', {'uid': user.id}));
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
    _userList.children.forEach((Element li) =>
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
