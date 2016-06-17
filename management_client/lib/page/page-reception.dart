library management_tool.page.reception;

import 'dart:async';
import 'dart:html';

import 'package:route_hierarchical/client.dart';

import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/view.dart' as view;

import 'package:openreception.framework/model.dart' as model;

class ReceptionView {
  static const String viewName = 'reception';

  final controller.Contact _contactController;
  final controller.Organization _organizationController;
  final controller.Reception _receptionController;
  final controller.Dialplan _dpController;
  final controller.Calendar _calendarController;
  final Router _router;

  final DivElement element = new DivElement()
    ..id = 'reception-page'
    ..hidden = true
    ..classes.addAll(['page']);

  final ButtonElement _createButton = new ButtonElement()
    ..text = 'Opret'
    ..classes.add('create');
  final SearchInputElement _searchBox = new SearchInputElement()
    ..id = 'reception-search-box'
    ..value = ''
    ..placeholder = 'Filter...';
  final UListElement _uiReceptionList = new UListElement()
    ..id = 'reception-list'
    ..classes.add('zebra-even');
  final UListElement _ulContactList = new UListElement()
    ..id = 'reception-contact-list'
    ..classes.add('zebra-odd');

  view.Reception _receptionView;

  List<model.ReceptionReference> receptions =
      new List<model.ReceptionReference>();

  /**
   *
   */
  ReceptionView(
      controller.Contact this._contactController,
      controller.Organization this._organizationController,
      controller.Reception this._receptionController,
      controller.Dialplan this._dpController,
      controller.Calendar this._calendarController,
      Router this._router) {
    _setupRouter();

    _receptionView = new view.Reception(_receptionController,
        _organizationController, _dpController, _calendarController);

    element.children = [
      new DivElement()
        ..id = 'reception-listing'
        ..children = [
          new DivElement()
            ..id = 'reception-controlbar'
            ..classes.add('basic3controls')
            ..children = [_createButton],
          _searchBox,
          _uiReceptionList
        ],
      new DivElement()
        ..id = 'reception-content'
        ..children = [_receptionView.element],
      new DivElement()
        ..id = 'reception-rightbar'
        ..children = [
          new DivElement()
            ..id = 'reception-contact-container'
            ..style.height = '99.5%'
            ..children = [
              new HeadingElement.h4()..text = 'Kontakter',
              _ulContactList
            ]
        ]
    ];

    _observers();
  }

  void _observers() {
    _createButton.onClick.listen((_) {
      _router.gotoUrl('reception/create');
    });

    _receptionView.changes.listen((view.ReceptionChange rc) async {
      await _refreshList();
      if (rc.type == view.Change.deleted) {} else if (rc.type ==
          view.Change.updated) {
        await _activateReception(rc.reception.id);
      } else if (rc.type == view.Change.created) {
        await _activateReception(rc.reception.id);
      }
    });

    _searchBox.onInput.listen((_) => _performSearch());
  }

  void _performSearch() {
    String searchText = _searchBox.value;
    List<model.ReceptionReference> filteredList = receptions
        .where((model.ReceptionReference recep) =>
            recep.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    _renderReceptionList(filteredList);
  }

  void _renderReceptionList(List<model.ReceptionReference> receptions) {
    _uiReceptionList.children
      ..clear()
      ..addAll(receptions.map(_makeReceptionNode));
  }

  /**
   *
   */
  Future _refreshList() {
    return _receptionController
        .list()
        .then((Iterable<model.ReceptionReference> receptions) {
      int compareTo(model.ReceptionReference r1, model.ReceptionReference r2) =>
          r1.name.compareTo(r2.name);

      List<model.ReceptionReference> list = receptions.toList()
        ..sort(compareTo);
      this.receptions = list;
      _performSearch();
    });
  }

  LIElement _makeReceptionNode(model.ReceptionReference rRef) {
    return new LIElement()
      ..classes.add('clickable')
      ..dataset['rid'] = '${rRef.id}'
      ..text = rRef.name
      ..onClick.listen((_) => _router.gotoUrl('/reception/edit/${rRef.id}'));
  }

  void _highlightContactInList(int id) {
    _uiReceptionList.children.forEach((Element li) =>
        li.classes.toggle('highlightListItem', li.dataset['rid'] == '$id'));
  }

  Future _activateReception(int receptionId) async {
    if (receptionId != model.Reception.noId) {
      _receptionView.reception = await _receptionController.get(receptionId);

      _highlightContactInList(receptionId);
      _updateContactList(receptionId);
    } else {
      _updateContactList(receptionId);
    }
  }

  /**
   *
   */
  Future _updateContactList(int receptionId) async {
    final Iterable<model.ReceptionContact> rc =
        await _contactController.receptionContacts(receptionId);

    List<model.ReceptionContact> sorted = rc.toList()
      ..sort(view.compareReceptionContacts);
    _ulContactList.children
      ..clear()
      ..addAll(sorted.map((model.ReceptionContact cRef) =>
          _makeContactNode(cRef.contact, receptionId)));
  }

  /**
   * TODO: Add function gear ⚙
   */
  LIElement _makeContactNode(model.BaseContact contact, int rid) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = contact.name
      ..onClick.listen((_) => _router.gotoUrl('/contact/edit/${contact.id}'));
    return li;
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

  Future activateCreate(RouteEvent e) async {
    _receptionView.reception = new model.Reception.empty();
    _receptionView.element.hidden = false;
  }

  /**
   *
   */
  Future activateEdit(RouteEvent e) async {
    final int rid = int.parse(e.parameters['rid']);
    await _activateReception(rid);
  }

  /**
   *
   */
  void _setupRouter() {
    print('setting up reception router');
    _router.root
      ..addRoute(
          name: 'reception',
          enter: activate,
          path: '/reception',
          leave: deactivate,
          mount: (router) => router
            ..addRoute(name: 'create', path: '/create', enter: activateCreate)
            ..addRoute(
                name: 'edit',
                path: '/edit',
                mount: (router) => router
                  ..addRoute(name: 'id', path: '/:rid', enter: activateEdit)));
  }
}
