library management_tool.page.reception;

import 'dart:async';
import 'dart:html';

import 'package:management_tool/eventbus.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/view.dart' as view;

import 'package:openreception_framework/model.dart' as ORModel;

class ReceptionView {
  static const String viewName = 'reception';

  final controller.Contact _contactController;
  final controller.Organization _organizationController;
  final controller.Reception _receptionController;

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

  List<ORModel.Reception> receptions = new List<ORModel.Reception>();

  /**
   *
   */
  ReceptionView(
      controller.Contact this._contactController,
      controller.Organization this._organizationController,
      controller.Reception this._receptionController) {
    _receptionView =
        new view.Reception(_receptionController, _organizationController);

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
            ..children = [
              new DivElement()
                ..children = [
                  new HeadingElement.h4()..text = 'Kontakter',
                  _ulContactList
                ]
            ]
        ]
    ];

    _observers();
  }

  void _observers() {
    _createButton.onClick.listen((_) {
      //_clearRightBar();
      _receptionView.reception = new ORModel.Reception.empty();
    });

    bus.on(WindowChanged).listen((WindowChanged event) async {
      element.hidden = false;
      if (event.window == viewName) {
        await _refreshList();
        if (event.data.containsKey('organization_id') &&
            event.data.containsKey('reception_id')) {
          await _activateReception(
              event.data['organization_id'], event.data['reception_id']);
        }
      } else {
        element.hidden = true;
      }
    });

    _receptionView.changes.listen((view.ReceptionChange rc) async {
      await _refreshList();
      if (rc.type == view.Change.deleted) {} else if (rc.type ==
          view.Change.updated) {
        await _activateReception(rc.reception.organizationId, rc.reception.ID);
      } else if (rc.type == view.Change.created) {
        await _activateReception(rc.reception.organizationId, rc.reception.ID);
      }
    });

    _searchBox.onInput.listen((_) => _performSearch());
  }

  void _performSearch() {
    String searchText = _searchBox.value;
    List<ORModel.Reception> filteredList = receptions
        .where((ORModel.Reception recep) =>
            recep.fullName.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    _renderReceptionList(filteredList);
  }

  void _renderReceptionList(List<ORModel.Reception> receptions) {
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
        .then((Iterable<ORModel.Reception> receptions) {
      int compareTo(ORModel.Reception r1, ORModel.Reception r2) =>
          r1.fullName.compareTo(r2.fullName);

      List list = receptions.toList()..sort(compareTo);
      this.receptions = list;
      _performSearch();
    });
  }

  LIElement _makeReceptionNode(ORModel.Reception reception) {
    return new LIElement()
      ..classes.add('clickable')
      ..dataset['receptionid'] = '${reception.ID}'
      ..text = reception.fullName
      ..onClick.listen((_) {
        _activateReception(reception.organizationId, reception.ID);
      });
  }

  void _highlightContactInList(int id) {
    _uiReceptionList.children.forEach((LIElement li) => li.classes
        .toggle('highlightListItem', li.dataset['receptionid'] == '$id'));
  }

  Future _activateReception(int organizationId, int receptionId) async {
    if (receptionId != ORModel.Reception.noID) {
      _receptionView.reception = await _receptionController.get(receptionId);

      _highlightContactInList(receptionId);
      _updateContactList(receptionId);
    } else {
      _updateContactList(receptionId);
    }
  }

  void _updateContactList(int receptionId) {
    _contactController
        .list(receptionId)
        .then((Iterable<ORModel.Contact> contacts) {
      int compareTo(ORModel.Contact c1, ORModel.Contact c2) =>
          c1.fullName.compareTo(c2.fullName);

      List<ORModel.Contact> sorted = contacts.toList()..sort(compareTo);
      _ulContactList.children
        ..clear()
        ..addAll(sorted.map((ORModel.Contact contact) =>
            makeContactNode(contact, receptionId)));
    });
  }

  LIElement makeContactNode(ORModel.Contact contact, int receptionId) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = contact.fullName
      ..onClick.listen((_) {
        Map data = {'contact_id': contact.ID, 'reception_id': receptionId};
        bus.fire(new WindowChanged('contact', data));
      });
    return li;
  }
}
