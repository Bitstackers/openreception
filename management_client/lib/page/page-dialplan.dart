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
    ..hidden = true
    ..classes.addAll(['page']);

  final controller.Dialplan _dialplanController;
  view.Dialplan _dpView;

  final ButtonElement _createButton = new ButtonElement()
    ..text = 'Opret'
    ..classes.add('create');

  final UListElement _userList = new UListElement()..classes.add('zebra-even');

  final UListElement _receptionsList = new UListElement()
    ..classes.add('zebra-odd');

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
      new DivElement()
        ..classes.add('page-content-with-rightbar')
        ..children = [_dpView.element],
      new DivElement()
        ..classes.add('rightbar')
        ..children = [
          new HeadingElement.h3()..text = 'Receptioner',
          _receptionsList
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

    _createButton.onClick.listen((_) => _createDialplan());

    _dpView.onDelete = ((_) {
      _userList.children.forEach(
          (LIElement li) => li.classes.toggle('highlightListItem', false));
    });

    _dpView.onUpdate = ((String extension) {
      _activateDialplan(extension);
    });
  }

  /**
   *
   */
  void _renderReceptionList(Iterable<model.Reception> receptions) {
    _receptionsList.children
      ..clear()
      ..addAll(receptions.map(_makeReceptionNode));
  }

  /**
   *
   */
  LIElement _makeReceptionNode(model.Reception reception) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${reception.fullName}'
      ..onClick.listen((_) {
        Map data = {
          'organization_id': reception.organizationId,
          'reception_id': reception.ID
        };
        bus.fire(new WindowChanged('reception', data));
      });
    return li;
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
      ..onClick.listen((_) => _activateDialplan(rdp.extension));
  }

  /**
   *
   */
  Future _activateDialplan(String extension) async {
    _log.finest('Activating dialplan ${extension}');
    _dpView.dialplan = await _dialplanController.get(extension);
    _highlightDialplanInList(extension);
    _renderReceptionList(await _dialplanController.listUsage(extension));
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
