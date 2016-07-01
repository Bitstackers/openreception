library management_tool.page.ivr;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/view.dart' as view;
import 'package:openreception.framework/model.dart' as model;
import 'package:route_hierarchical/client.dart';

const String _libraryName = 'management_tool.page.ivr';

/**
 *
 */
class Ivr {
  final Logger _log = new Logger('$_libraryName.Ivr');

  final DivElement element = new DivElement()
    ..id = "calendar-page"
    ..hidden = true
    ..classes.addAll(['page']);

  final controller.Ivr _menuController;
  final Router _router;

  view.IvrMenu _ivrView;

  final ButtonElement _createButton = new ButtonElement()
    ..text = 'Opret'
    ..classes.add('create');

  final UListElement _userList = new UListElement()..classes.add('zebra-even');

  final UListElement _dialplanList = new UListElement()
    ..classes.add('zebra-odd');

  /**
   *
   */
  Ivr(this._menuController, this._router) {
    _setupRouter();

    _ivrView = new view.IvrMenu(_menuController);

    element.children = [
      (new DivElement()
        ..classes.add('object-listing')
        ..children = [
          new DivElement()
            ..classes.add('basic3controls')
            ..children = [_createButton],
          _userList,
        ]),
      new DivElement()
        ..classes.add('page-content-with-rightbar')
        ..children = [_ivrView.element],
      new DivElement()
        ..classes.add('rightbar')
        ..children = [
          new HeadingElement.h3()..text = 'Kaldplaner',
          _dialplanList
        ]
    ];
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _createButton.onClick.listen((_) => _router.gotoUrl('/ivr/create'));

    _ivrView.onDelete = ((_) async {
      await _refreshList();
      _userList.children.forEach(
          (Element li) => li.classes.toggle('highlightListItem', false));
    });

    _ivrView.onUpdate = ((String menuName) async {
      await _refreshList();
      await _activateIvrmenu(menuName);
    });
  }

  /**
   *
   */
  void _renderDialplanList(Iterable<model.ReceptionDialplan> rdps) {
    _dialplanList.children
      ..clear()
      ..addAll(rdps.map(_makeDialplanNode));
  }

  /**
   *
   */
  LIElement _makeDialplanNode(model.ReceptionDialplan rdp) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${rdp.extension}'
      ..onClick
          .listen((_) => _router.gotoUrl('/dialplan/edit/${rdp.extension}'));
    return li;
  }

  /**
   *
   */
  Future _refreshList() async {
    final menus = (await _menuController.list()).toList()
      ..sort((model.IvrMenu menuA, model.IvrMenu menuB) =>
          menuA.name.toLowerCase().compareTo(menuB.name.toLowerCase()));

    _renderIvrmenuList(menus);
  }

  /**
   *
   */
  void _renderIvrmenuList(Iterable<model.IvrMenu> menus) {
    _userList.children
      ..clear()
      ..addAll(menus.map(_makeIvrmenuNode));
  }

  /**
   *
   */
  LIElement _makeIvrmenuNode(model.IvrMenu menu) {
    return new LIElement()
      ..text = menu.name
      ..classes.add('clickable')
      ..dataset['name'] = '${menu.name}'
      ..onClick.listen((_) => _activateIvrmenu(menu.name));
  }

  /**
   *
   */
  Future _activateIvrmenu(String name) async {
    _log.finest('Activating menu ${name}');
    _ivrView.menu = await _menuController.get(name);
    _ivrView.create = false;
    _highlightIvrmenuInList(name);

    _renderDialplanList(await _menuController.listUsage(name));
  }

  /**
   *
   */
  void _highlightIvrmenuInList(String name) {
    _userList.children.forEach((Element li) =>
        li.classes.toggle('highlightListItem', li.dataset['name'] == '$name'));
  }

  /**
   *
   */
  void _createIvrMenu(RouteEvent e) {
    _ivrView.menu =
        new model.IvrMenu('ny-menu', new model.Playback('velkomst.wav'));
    _ivrView.create = true;

    _renderDialplanList([]);
    _highlightIvrmenuInList('ny-menu');
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

  Future _editIvrMenu(RouteEvent e) async {
    final menu = e.parameters['menu'];
    await _activateIvrmenu(menu);
  }

  /**
   *
   */
  void _setupRouter() {
    print('setting up ivr router');
    _router.root
      ..addRoute(
          name: 'ivr',
          enter: activate,
          path: '/ivr',
          leave: deactivate,
          mount: (router) => router
            ..addRoute(name: 'create', path: '/create', enter: _createIvrMenu)
            ..addRoute(
                name: 'edit',
                path: '/edit',
                mount: (router) => router
                  ..addRoute(
                      name: 'menu', path: '/:menu', enter: _editIvrMenu)));
  }
}
