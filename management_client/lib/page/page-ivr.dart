library management_tool.page.ivr;

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
class Ivr {
  static const String _viewName = 'ivr';
  final Logger _log = new Logger('$_libraryName.Ivr');

  final DivElement element = new DivElement()
    ..id = "calendar-page"
    ..classes.addAll(['hidden', 'page']);

  final controller.Ivr _ivrController;
  //view.Ivr _ivrView;

  final ButtonElement _createButton = new ButtonElement()
    ..text = 'Opret'
    ..classes.add('create');

  final UListElement _userList = new UListElement()
    ..id = 'user-list'
    ..classes.add('zebra-even');

  /**
   *
   */
  Ivr(this._ivrController) {
    //_ivrView = new view.Ivr(_dialplanController);

    element.children = [
      (new DivElement()
        ..classes.add('object-listing')
        ..children = [
          new DivElement()
            ..classes.add('basic3controls')
            ..children = [_createButton],
          _userList,
        ]),
    ];

    _refreshList();
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    bus.on(WindowChanged).listen((WindowChanged event) {
      element.classes.toggle('hidden', event.window != _viewName);
    });

    _createButton.onClick.listen((_) => _createDialplan());
  }

  /**
   *
   */
  Future _refreshList() async {
    final menus = (await _ivrController.list()).toList()
      ..sort((model.IvrMenu menuA, model.IvrMenu menuB) =>
          menuA.name.toLowerCase().compareTo(menuB.name.toLowerCase()));

    _renderDialplanList(menus);
  }

  /**
   *
   */
  void _renderDialplanList(Iterable<model.IvrMenu> menus) {
    _userList.children
      ..clear()
      ..addAll(menus.map(_makeMenuNode));
  }

  /**
   *
   */
  LIElement _makeMenuNode(model.IvrMenu menu) {
    return new LIElement()
      ..text = menu.name
      ..classes.add('clickable')
      ..dataset['ivr-name'] = '${menu.name}'
      ..onClick.listen((_) => _activateIvrMenu(menu));
  }

  /**
   *
   */
  Future _activateIvrMenu(model.IvrMenu menu) async {
    _log.finest('Activating dialplan ${menu.name}');
    _highlightDialplanInList(menu.name);
    //_ivrView.menu = menu;
    _highlightDialplanInList(menu.name);
  }

  /**
   *
   */
  void _highlightDialplanInList(String exten) {
    _userList.children.forEach((LIElement li) => li.classes
        .toggle('highlightListItem', li.dataset['extension'] == '$exten'));
  }

  /**
   *
   */
  void _createDialplan() {
    //_ivrView.dialplan = new model.ReceptionDialplan();
    _highlightDialplanInList('');
  }
}
