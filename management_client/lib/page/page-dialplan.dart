library management_tool.page.dialplan;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/eventbus.dart';
import 'package:management_tool/view.dart' as view;
import 'package:openreception_framework/model.dart' as model;

const String _libraryName = 'management_tool.page.dialplan';

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
  view.DialplanCalenderPlot _dpPlot;

  final ButtonElement _createButton = new ButtonElement()
    ..text = 'Opret'
    ..classes.add('create');

  final UListElement _userList = new UListElement()..classes.add('zebra-even');

  final UListElement _receptionsList = new UListElement()
    ..classes.add('zebra-odd');

  /**
   *
   */
  Dialplan(this._dialplanController) {
    _dpView = new view.Dialplan(_dialplanController);
    _dpPlot = new view.DialplanCalenderPlot();

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
        ..children = [_dpView.element, _dpPlot.element],
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

        if (event.data.containsKey('extension')) {
          _activateDialplan(event.data['extension']);
        }
      } else {
        element.hidden = true;
      }
    });

    _createButton.onClick.listen((_) => _createDialplan());

    _dpView.onDelete = (_) async {
      await _refreshList();
    };

    _dpView.onUpdate = (String extension) async {
      await _refreshList();
      await _activateDialplan(extension);
    };

    _dpView.onChange = () {
      if (_dpView.hasValidationError) {
        _dpPlot.dim();
      } else {
        _dpPlot.dialplan = _dpView.dialplan;
      }
    };
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
    _dpPlot.dialplan = _dpView.dialplan;
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
