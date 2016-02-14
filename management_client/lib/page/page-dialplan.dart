library management_tool.page.dialplan;

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
class Dialplan {
  static const String _viewName = 'dialplan';
  final Logger _log = new Logger('$_libraryName.Dialplan');

  final DivElement element = new DivElement()
    ..id = "calendar-page"
    ..classes.addAll(['hidden', 'page']);

  final controller.Dialplan _dialplanController;
  view.Dialplan _dpView;

  final ButtonElement _createButton = new ButtonElement()
    ..text = 'Opret'
    ..classes.add('create');

  final UListElement _userList = new UListElement()
    ..id = 'user-list'
    ..classes.add('zebra-even');

  /// Extracts the uid of the currently selected user.
  model.ReceptionDialplan get selectedDialplan => _dpView.dialplan;

  /**
   *
   */
  Dialplan(this._dialplanController) {
    _dpView = new view.Dialplan(_dialplanController);

    element.children = [
      (new DivElement()
        ..classes.add('object-listing')
        ..children = [
          new DivElement()
            ..classes.add('basic3controls')
            ..children = [_createButton],
          _userList,
        ]),
      _dpView.element
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
    final rdps = (await _dialplanController.list()).toList()
      ..sort((model.ReceptionDialplan rdpA, model.ReceptionDialplan rdpB) =>
          rdpA.extension.toLowerCase().compareTo(rdpB.extension.toLowerCase()));

    _renderDialplanList(rdps);
  }

  /**
   *
   */
  void _renderDialplanList(Iterable<model.ReceptionDialplan> rdps) {
    _userList.children
      ..clear()
      ..addAll(rdps.map(_makeDialplanNode));
  }

  /**
   *
   */
  LIElement _makeDialplanNode(model.ReceptionDialplan rdp) {
    return new LIElement()
      ..text = rdp.extension
      ..classes.add('clickable')
      ..dataset['extension'] = '${rdp.extension}'
      ..onClick.listen((_) => _activateDialplan(rdp));
  }

  /**
   *
   */
  Future _activateDialplan(model.ReceptionDialplan rdp) async {
    _log.finest('Activating dialplan ${rdp.extension}');
    _highlightDialplanInList(rdp.extension);
    _dpView.dialplan = rdp;
    _highlightDialplanInList(_dpView.dialplan.extension);
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
    _dpView.dialplan = new model.ReceptionDialplan();
    _highlightDialplanInList('');
  }
}
