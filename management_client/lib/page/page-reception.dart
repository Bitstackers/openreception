library orm.page.reception;

import 'dart:async';
import 'dart:html';

import 'package:orm/configuration.dart';
import 'package:orm/controller.dart' as controller;
import 'package:orm/view.dart' as view;
import 'package:orf/event.dart' as event;
import 'package:orf/model.dart' as model;
import 'package:route_hierarchical/client.dart';

class Reception {
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
  Reception(
      controller.Contact this._contactController,
      controller.Organization this._organizationController,
      controller.Reception this._receptionController,
      controller.Dialplan this._dpController,
      controller.Calendar this._calendarController,
      Stream<event.ReceptionChange> receptionChanges,
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

    _observers(receptionChanges);
  }

  void _observers(Stream<event.ReceptionChange> receptionChanges) {
    _createButton.onClick.listen((_) {
      _router.go('reception.create', {});
    });

    receptionChanges.listen((event.ReceptionChange e) async {
      if (!this.element.hidden) {
        /// Always refresh the userlist
        await _refreshList();

        /// This is the currently selected organization
        if (e.rid == _receptionView.reception.id) {
          if (e.isDelete) {
            _receptionView.clear();
            _receptionView.hidden = true;
            _renderReceptionList([]);
            _router.go('reception', {});
          } else if (e.isUpdate) {
            _router.go('reception.edit.id', {'rid': e.rid});
          }
        } else if (e.isCreate && e.modifierUid == config.user.id) {
          _router.go('reception.edit.id', {'rid': e.rid});
        }
      }
    });

    _searchBox.onInput.listen((_) => _performSearch());
  }

  /**
   *
   */
  void _performSearch() {
    String searchText = _searchBox.value;
    List<model.ReceptionReference> filteredList = receptions
        .where((model.ReceptionReference recep) =>
            recep.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    _renderReceptionList(filteredList);
  }

  /**
   *
   */
  void _renderReceptionList(List<model.ReceptionReference> receptions) {
    _uiReceptionList.children =
        new List<LIElement>.from(receptions.map(_makeReceptionNode));
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
      ..onClick
          .listen((_) => _router.go('reception.edit.id', {'rid': rRef.id}));
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

  /// Build an [LIElement] HTML node from a [model.BaseContact] object.
  LIElement _makeContactNode(model.BaseContact contact, int rid) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = contact.type == 'function' ? '⚙ ${contact.name}' : contact.name
      ..onClick
          .listen((_) => _router.go('contact.edit.id', {'cid': contact.id}));
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
