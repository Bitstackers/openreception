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
  final controller.Dialplan _dpController;
  final controller.Calendar _calendarController;

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

  List<ORModel.ReceptionReference> receptions =
      new List<ORModel.ReceptionReference>();

  /**
   *
   */
  ReceptionView(
      controller.Contact this._contactController,
      controller.Organization this._organizationController,
      controller.Reception this._receptionController,
      controller.Dialplan this._dpController,
      controller.Calendar this._calendarController) {
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
          await _activateReception(event.data['reception_id']);
        }
      } else {
        element.hidden = true;
      }
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
    List<ORModel.ReceptionReference> filteredList = receptions
        .where((ORModel.ReceptionReference recep) =>
            recep.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    _renderReceptionList(filteredList);
  }

  void _renderReceptionList(List<ORModel.ReceptionReference> receptions) {
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
        .then((Iterable<ORModel.ReceptionReference> receptions) {
      int compareTo(
              ORModel.ReceptionReference r1, ORModel.ReceptionReference r2) =>
          r1.name.compareTo(r2.name);

      List list = receptions.toList()..sort(compareTo);
      this.receptions = list;
      _performSearch();
    });
  }

  LIElement _makeReceptionNode(ORModel.ReceptionReference rRef) {
    return new LIElement()
      ..classes.add('clickable')
      ..dataset['receptionid'] = '${rRef.id}'
      ..text = rRef.name
      ..onClick.listen((_) {
        _activateReception(rRef.id);
      });
  }

  void _highlightContactInList(int id) {
    _uiReceptionList.children.forEach((LIElement li) => li.classes
        .toggle('highlightListItem', li.dataset['receptionid'] == '$id'));
  }

  Future _activateReception(int receptionId) async {
    if (receptionId != ORModel.Reception.noId) {
      _receptionView.reception = await _receptionController.get(receptionId);

      _highlightContactInList(receptionId);
      _updateContactList(receptionId);
    } else {
      _updateContactList(receptionId);
    }
  }

  void _updateContactList(int receptionId) {
    _contactController
        .receptionAttributes(receptionId)
        .then((Iterable<ORModel.ReceptionAttributes> attrs) {
      int compareTo(
              ORModel.ReceptionAttributes c1, ORModel.ReceptionAttributes c2) =>
          c1.reference.reception.name.compareTo(c2.reference.reception.name);

      List<ORModel.ReceptionAttributes> sorted = attrs.toList()
        ..sort(compareTo);
      _ulContactList.children
        ..clear()
        ..addAll(sorted.map((ORModel.ReceptionAttributes attr) =>
            makeContactNode(attr, receptionId)));
    });
  }

  LIElement makeContactNode(ORModel.ReceptionAttributes attr, int rid) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = attr.reference.reception.name
      ..onClick.listen((_) {
        Map data = {'contact_id': attr.contactId, 'reception_id': rid};
        bus.fire(new WindowChanged('contact', data));
      });
    return li;
  }
}
