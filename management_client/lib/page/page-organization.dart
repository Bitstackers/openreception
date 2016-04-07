library management_tool.page.organization;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:management_tool/eventbus.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/view.dart' as view;

import 'package:openreception_framework/model.dart' as ORModel;

controller.Popup notify = controller.popup;

const String _libraryName = 'management_tool.page.organization';

class OrganizationView {
  static const String viewName = 'organization';

  Logger _log = new Logger('$_libraryName.Organization');

  final controller.Organization _organizationController;
  final controller.Reception _receptionController;

  final DivElement element = new DivElement()
    ..id = "organization-page"
    ..hidden = true
    ..classes.add('page');
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

  List<ORModel.OrganizationReference> _organizations =
      new List<ORModel.OrganizationReference>();

  List<ORModel.ContactReference> _currentContactList =
      new List<ORModel.ContactReference>();
  List<ORModel.ReceptionReference> _currentReceptionList =
      new List<ORModel.ReceptionReference>();

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
  }

  /**
   *
   */
  void _observers() {
    _createButton.onClick.listen((_) {
      _clearRightBar();
      _organizationView.organization = new ORModel.Organization.empty();
    });

    bus.on(WindowChanged).listen((WindowChanged event) async {
      if (event.window == viewName) {
        element.hidden = false;
        await _refreshList();
        if (event.data.containsKey('organization_id')) {
          _activateOrganization(event.data['organization_id']);
        }
      } else {
        element.hidden = true;
      }
    });

    _searchBox.onInput.listen((_) => _performSearch());

    _organizationView.changes.listen((view.OrganizationChange ogc) async {
      await _refreshList();
      if (ogc.type == view.Change.deleted) {} else if (ogc.type ==
          view.Change.updated) {
        await _activateOrganization(ogc.organization.id);
      } else if (ogc.type == view.Change.created) {
        await _activateOrganization(ogc.organization.id);
      }
    });
  }

  void _clearRightBar() {
    _currentReceptionList.clear();
    _ulContactList.children.clear();
    _ulReceptionList.children.clear();
  }

  /**
   *
   */
  void _performSearch() {
    String searchText = _searchBox.value;
    List<ORModel.OrganizationReference> filteredList = _organizations
        .where((ORModel.OrganizationReference org) =>
            org.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    _renderOrganizationList(filteredList);
  }

  /**
   *
   */
  Future _refreshList() async {
    await _organizationController
        .list()
        .then((Iterable<ORModel.OrganizationReference> organizations) {
      int compareTo(ORModel.OrganizationReference org1,
              ORModel.OrganizationReference org2) =>
          org1.name.compareTo(org2.name);

      List list = organizations.toList()..sort(compareTo);
      this._organizations = list;
      _renderOrganizationList(list);
    }).catchError((error) {
      notify.error('Organisationsliste kunne ikke hentes', 'Fejl: $error');
      _log.severe('Tried to fetch organization list, got error: $error');
    });
  }

  void _renderOrganizationList(
      List<ORModel.OrganizationReference> organizations) {
    _orgUList.children
      ..clear()
      ..addAll(organizations.map(_makeOrganizationNode));
  }

  LIElement _makeOrganizationNode(ORModel.OrganizationReference organization) {
    return new LIElement()
      ..classes.add('clickable')
      ..dataset['organizationid'] = '${organization.id}'
      ..text = '${organization.name}'
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
          'Kunne ikke hente stamdata for organisation oid:$organizationId',
          'Fejl: $error');
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
        .then((Iterable<ORModel.ReceptionReference> rRefs) {
      _currentReceptionList = rRefs.toList();
      _ulReceptionList.children
        ..clear()
        ..addAll(rRefs.map(_makeReceptionNode));
    });
  }

  LIElement _makeReceptionNode(ORModel.ReceptionReference rRef) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${rRef.name}'
      ..onClick.listen((_) {
        Map data = {'reception_id': rRef.id};
        bus.fire(new WindowChanged('reception', data));
      });
    return li;
  }

  void _updateContactList(int organizationId) {
    _organizationController
        .contacts(organizationId)
        .then((Iterable<ORModel.ContactReference> contacts) {
      int compareTo(ORModel.ContactReference c1, ORModel.ContactReference c2) =>
          c1.name.toLowerCase().compareTo(c2.name.toLowerCase());

      List sorted = contacts.toList()..sort(compareTo);

      _currentContactList = sorted
          .map((c) => new ORModel.BaseContact.empty()
            ..id = c.id
            ..name = c.name)
          .toList();

      _ulContactList.children
        ..clear()
        ..addAll(sorted.map(_makeContactNode));
    }).catchError((error) {
      notify.error('Kunne ikke hente organisationskontakter', 'Fejl: $error');
      _log.severe(
          'Tried to fetch the contactlist from an organization Error: $error');
    });
  }

  LIElement _makeContactNode(ORModel.ContactReference cRef) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${cRef.name}'
      ..onClick.listen((_) {
        Map data = {'contact_id': cRef.id};
        bus.fire(new WindowChanged('contact', data));
      });
    return li;
  }
}
