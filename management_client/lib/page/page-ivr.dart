library management_tool.page.ivr;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/eventbus.dart';
import 'package:management_tool/view.dart' as view;
import 'package:openreception_framework/model.dart' as model;

const String _libraryName = 'management_tool.page.ivr';

/**
 *
 */
class Ivr {
  static const String _viewName = 'ivr';
  final Logger _log = new Logger('$_libraryName.Ivr');

  final DivElement element = new DivElement()
    ..id = "calendar-page"
    ..hidden = true
    ..classes.addAll(['page']);

  final controller.Ivr _menuController;
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
  Ivr(this._menuController) {
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
    bus.on(WindowChanged).listen((WindowChanged event) async {
      if (event.window == _viewName) {
        element.hidden = false;
        await _refreshList();
      } else {
        element.hidden = true;
      }
    });

    _createButton.onClick.listen((_) => _createIvrMenu());

    _ivrView.onDelete = ((_) async {
      await _refreshList();
      _userList.children.forEach(
          (LIElement li) => li.classes.toggle('highlightListItem', false));
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
      ..onClick.listen((_) {
        Map data = {'extension': rdp.extension};
        bus.fire(new WindowChanged('dialplan', data));
      });
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
    _highlightIvrmenuInList(name);

    _renderDialplanList(await _menuController.listUsage(name));
  }

  /**
   *
   */
  void _highlightIvrmenuInList(String name) {
    _userList.children.forEach((LIElement li) =>
        li.classes.toggle('highlightListItem', li.dataset['name'] == '$name'));
  }

  /**
   *
   */
  void _createIvrMenu() {
    _ivrView.menu =
        new model.IvrMenu('ny-menu', new model.Playback('velkomst.wav'));
    _ivrView.create = true;
    _highlightIvrmenuInList('ny-menu');
  }
}
