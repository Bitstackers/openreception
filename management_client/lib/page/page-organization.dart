library management_tool.page.organization;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:management_tool/eventbus.dart';
import 'package:management_tool/notification.dart' as notify;
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/view.dart' as view;

import 'package:openreception_framework/model.dart' as ORModel;

const String _libraryName = 'management_tool.page.organization';

class OrganizationView {
  static const String viewName = 'organization';

  Logger _log = new Logger('$_libraryName.Organization');

  final controller.Organization _organizationController;
  final controller.Reception _receptionController;

  final DivElement element = new DivElement()
    ..id = "organization-page"
    ..classes.add('hidden');
  final UListElement _orgUList = new UListElement()
    ..id = 'organization-list'
    ..classes.add('zebra-even');

  final ButtonElement _createButton = new ButtonElement()
    ..text = 'Opret'
    ..classes.add('create');

  final SearchInputElement _searchBox = new SearchInputElement()
    ..id = 'organization-search-box'
    ..value = ''
    ..placeholder = 'Filter...';
  final UListElement _ulReceptionList = new UListElement()
    ..id = 'organization-reception-list'
    ..classes.add('zebra-odd');
  final UListElement _ulContactList = new UListElement()
    ..id = 'organization-contact-list'
    ..classes.add('zebra-odd');

  view.Organization _organizationView;

  List<ORModel.Organization> _organizations = new List<ORModel.Organization>();

  List<ORModel.Contact> _currentContactList = new List<ORModel.Contact>();
  List<ORModel.Reception> _currentReceptionList = new List<ORModel.Reception>();

  /**
   *
   */
  OrganizationView(controller.Organization this._organizationController,
      controller.Reception this._receptionController) {

    _organizationView = new view.Organization(_organizationController);

    element.children = [
      new DivElement()
        ..id = 'organization-listing'
        ..children = [
          new DivElement()
            ..id = "user-controlbar"
            ..classes.add('basic3controls')
            ..children = [_createButton],
          _searchBox,
          _orgUList,
        ],
      new DivElement()
        ..id = 'organization-content'
        ..children = [_organizationView.element],
      new DivElement()
        ..id = 'organization-rightbar'
        ..children = [
          new DivElement()
            ..id = 'organization-reception-container'
            ..children = [
              new DivElement()
                ..children = [
                  new HeadingElement.h4()..text = 'Receptioner',
                  _ulReceptionList
                ]
            ],
          new DivElement()
            ..id = 'organization-contact-container'
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

    _refreshList();
  }

  /**
   *
   */
  void _observers() {
    _createButton.onClick.listen((_) {
      _clearRightBar();
      _organizationView.organization = new ORModel.Organization.empty();
    });

    bus.on(WindowChanged).listen((WindowChanged event) {
      element.classes.toggle('hidden', event.window != viewName);
      if (event.data.containsKey('organization_id')) {
        _activateOrganization(event.data['organization_id']);
      }
    });

    _searchBox.onInput.listen((_) => _performSearch());


    _organizationView.changes.listen((view.OrganizationChange ogc) async {
      await _refreshList();
      if (ogc.type == view.Change.deleted) {

      } else if (ogc.type == view.Change.updated) {

        await _activateOrganization(ogc.organization.id);
      } else if (ogc.type == view.Change.created) {

        await _activateOrganization(ogc.organization.id);
      }
    });
  }

  void _clearRightBar() {
    _currentContactList.clear();
    _currentReceptionList.clear();
    _ulContactList.children.clear();
    _ulReceptionList.children.clear();
  }

  /**
   *
   */
  void _performSearch() {
    String searchText = _searchBox.value;
    List<ORModel.Organization> filteredList = _organizations
        .where((ORModel.Organization org) =>
            org.fullName.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    _renderOrganizationList(filteredList);
  }


  /**
   *
   */
  Future _refreshList() async {
    await _organizationController
        .list()
        .then((Iterable<ORModel.Organization> organizations) {
      int compareTo(ORModel.Organization org1, ORModel.Organization org2) =>
          org1.fullName.compareTo(org2.fullName);

      List list = organizations.toList()..sort(compareTo);
      this._organizations = list;
      _renderOrganizationList(list);
    }).catchError((error) {
      notify.error('Organisationerne blev ikke hentet da der er sket en fejl.');
      _log.severe('Tried to fetch organization list, got error: $error');
    });
  }

  void _renderOrganizationList(List<ORModel.Organization> organizations) {
    _orgUList.children
      ..clear()
      ..addAll(organizations.map(_makeOrganizationNode));
  }

  LIElement _makeOrganizationNode(ORModel.Organization organization) {
    return new LIElement()
      ..classes.add('clickable')
      ..dataset['organizationid'] = '${organization.id}'
      ..text = '${organization.fullName}'
      ..onClick.listen((_) {
        _activateOrganization(organization.id);
      });
  }

  void _highlightOrganizationInList(int id) {
    _orgUList.children.forEach((LIElement li) => li.classes
        .toggle('highlightListItem', li.dataset['organizationid'] == '$id'));
  }

  Future _activateOrganization(int organizationId) async {
    try {
      _organizationView.organization =
          await _organizationController.get(organizationId);
    } catch (error) {
      notify.error(
          'Der skete en fejl i forbindelse med at hente alt information for organisationen.');
      _log.severe(
          'Tried to activate organization "$organizationId" but gave error: $error');
    }

    _highlightOrganizationInList(organizationId);

    _updateReceptionList(organizationId);
    _updateContactList(organizationId);
  }

  void _updateReceptionList(int organizationId) {
    _organizationController
        .receptions(organizationId)
        .then((Iterable<int> receptionIDs) {
      List list = [];
      Future
          .forEach(receptionIDs,
              (int id) => _receptionController.get(id).then(list.add))
          .then((_) {
        list.sort(_compareReception);
        _currentReceptionList = list;
        _ulReceptionList.children
          ..clear()
          ..addAll(list.map(_makeReceptionNode));
      });
    });
  }

  LIElement _makeReceptionNode(ORModel.Reception reception) {
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

  void _updateContactList(int organizationId) {
    _organizationController
        .contacts(organizationId)
        .then((Iterable<ORModel.BaseContact> contacts) {
      int compareTo(ORModel.BaseContact c1, ORModel.BaseContact c2) =>
          c1.fullName.compareTo(c2.fullName);

      List list = contacts.toList()..sort(compareTo);

      _currentContactList = list;
      _ulContactList.children
        ..clear()
        ..addAll(list.map(_makeContactNode));
    }).catchError((error) {
      notify.error(
          'Der skete en fejl i forbindelse med at hente kontakterne tilknyttet organisationen.');
      _log.severe(
          'Tried to fetch the contactlist from an organization Error: $error');
    });
  }

  LIElement _makeContactNode(ORModel.BaseContact contact) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${contact.fullName}'
      ..onClick.listen((_) {
        Map data = {'contact_id': contact.id};
        bus.fire(new WindowChanged('contact', data));
      });
    return li;
  }
}

int _compareReception(ORModel.Reception r1, ORModel.Reception r2) =>
    r1.fullName.compareTo(r2.fullName);
