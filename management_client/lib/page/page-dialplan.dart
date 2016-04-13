library management_tool.page.dialplan;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:route_hierarchical/client.dart';

import 'package:management_tool/controller.dart' as controller;
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
  final Router _router;

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
  Dialplan(this._dialplanController, this._router) {
    _setupRouter();
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
    _createButton.onClick.listen((_) => _router.gotoUrl('/dialplan/create'));

    _dpView.onDelete = (_) async {
      await _refreshList();
      _dpPlot.element.hidden = true;
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
  void _renderReceptionList(Iterable<model.ReceptionReference> rRefs) {
    _receptionsList.children
      ..clear()
      ..addAll(rRefs.map(_makeReceptionNode));
  }

  /**
   *
   */
  LIElement _makeReceptionNode(model.ReceptionReference rRef) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${rRef.name}'
      ..onClick.listen((_) => _router.gotoUrl('/reception/edit/${rRef.id}'));
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
      ..onClick
          .listen((_) => _router.gotoUrl('/dialplan/edit/${rdp.extension}'));
  }

  /**
   *
   */
  Future _activateDialplan(String extension) async {
    _log.finest('Activating dialplan ${extension}');
    _dpView.dialplan = await _dialplanController.get(extension);
    _dpPlot.dialplan = _dpView.dialplan;
    _dpView.create = false;
    _highlightDialplanInList(extension);
    _renderReceptionList(
        [(await _dialplanController.getByExtensions(extension)).reference]);
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
  Future _createDialplan(RouteEvent e) async {
    _dpView.dialplan = new model.ReceptionDialplan();
    _dpView.create = true;
    _renderReceptionList([]);
    _highlightDialplanInList('');
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

  Future _activateEdit(RouteEvent e) async {
    final extension = e.parameters['extension'];

    await _activateDialplan(extension);
  }

  /**
   *
   */
  void _setupRouter() {
    print('setting up dialplan router');
    _router.root
      ..addRoute(
          name: 'dialplan',
          enter: activate,
          path: '/dialplan',
          leave: deactivate,
          mount: (router) => router
            ..addRoute(name: 'create', path: '/create', enter: _createDialplan)
            ..addRoute(
                name: 'edit',
                path: '/edit',
                mount: (router) => router
                  ..addRoute(
                      name: 'extension',
                      path: '/:extension',
                      enter: _activateEdit)));
  }
}
