library management_tool.page.contact;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';

import 'package:management_tool/eventbus.dart';
import 'package:management_tool/view.dart' as view;

import 'package:openreception_framework/event.dart' as event;
import 'package:openreception_framework/model.dart' as model;

import 'package:management_tool/controller.dart' as controller;

const String _libraryName = 'contact.view';

controller.Popup notify = controller.popup;

class ContactView {
  static const String _viewName = 'contact';
  final Logger _log = new Logger('$_libraryName.Contact');
  DivElement element;

  SearchInputElement _searchBox;

  final controller.Contact _contactController;
  final controller.Calendar _calendarController;
  final controller.Reception _receptionController;
  final controller.Notification _notificationController;

  UListElement _ulContactList;
  UListElement _ulReceptionData;
  UListElement _ulReceptionList;
  UListElement _ulOrganizationList;
  List<model.ContactReference> _contactList =
      new List<model.ContactReference>();

  final ButtonElement _createButton = new ButtonElement()
    ..id = 'contact-create'
    ..text = 'Opret'
    ..classes.add('create');

  view.Contact _contactData;
  static const List<String> phonenumberTypes = const ['PSTN', 'SIP'];

  bool get isHidden => element.classes.contains('hidden');

  ContactView(
      DivElement this.element,
      this._contactController,
      this._receptionController,
      this._calendarController,
      this._notificationController) {
    _searchBox = element.querySelector('#contact-search-box');

    _contactData = new view.Contact(
        _contactController, _calendarController, _receptionController);

    element.querySelector('#contact-create').replaceWith(_createButton);
    element
        .querySelector('#contact-base-info')
        .replaceWith(_contactData.element);

    _ulContactList = element.querySelector('#contact-list');
    element.classes.add('page');

    _observers();

    _refreshList();
    _ulReceptionData = element.querySelector('#reception-contacts');
    _ulReceptionList = element.querySelector('#contact-reception-list');
    _ulOrganizationList = element.querySelector('#contact-organization-list');
  }

  /**
   *
   */
  void _observers() {
    bus.on(WindowChanged).listen((WindowChanged event) async {
      element.classes.toggle('hidden', event.window != _viewName);
      if (event.data.containsKey('contact_id')) {
        _contactData.contact =
            await _contactController.get(event.data['contact_id']);
      }
    });

    _notificationController.contactChange.listen((event.ContactChange e) async {
      if (isHidden) {
        return;
      }

      _refreshList();

      if (e.updated && _contactData.contact.id == e.cid) {
        _contactData.contact = await _contactController.get(e.cid);

        controller.popup.info(
            'Valgte kontakperson ændret af ${e.modifierUid} - opdaterer datablad',
            '');
      } else if (e.deleted && _contactData.contact.id == e.cid) {
        _clearContent();
        controller.popup.info(
            'Valgte kontakperson slettet af ${e.modifierUid} - rydder datablad',
            '');
      }
    });

    _createButton.onClick.listen((_) {
      _contactData.contact = new model.BaseContact.empty();
    });

    _searchBox.onInput.listen((_) => _performSearch());
  }

  void _performSearch() {
    String searchTerm = _searchBox.value;
    _ulContactList.children
      ..clear()
      ..addAll(_contactList
          .where((model.ContactReference contact) =>
              contact.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .map(_makeContactNode));
  }

  void _refreshList() {
    _contactController.list().then((Iterable<model.ContactReference> cRefs) {
      int compareTo(model.ContactReference c1, model.ContactReference c2) =>
          c1.name.compareTo(c2.name);

      List<model.ContactReference> list = cRefs.toList()..sort(compareTo);
      this._contactList = list;
      _performSearch();
    }).catchError((error) {
      _log.severe('Tried to fetch organization but got error: $error');
    });
  }

  LIElement _makeContactNode(model.ContactReference contact) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${contact.name}'
      ..dataset['contactid'] = '${contact.id}'
      ..onClick.listen((_) async {
        await _activateContact(contact.id);
      });

    return li;
  }

  void _highlightContactInList(int id) {
    _ulContactList.children.forEach((LIElement li) => li.classes
        .toggle('highlightListItem', li.dataset['contactid'] == '$id'));
  }

  /**
   *
   */
  Future _activateContact(int cid) async {
    _contactData.contact = await _contactController.get(cid);

    _highlightContactInList(cid);

    final Iterable<model.ReceptionReference> rRefs =
        await _contactController.receptions(cid);

    _ulReceptionData.children = new List.from(
        await Future.wait(rRefs.map((model.ReceptionReference rRef) {
      return _contactController
          .getByReception(cid, rRef.id)
          .then((model.ReceptionAttributes attr) {
        view.ReceptionContact rcView = new view.ReceptionContact(
            _receptionController, _contactController, rRefs.length == 1)
          ..attributes = attr;

        return rcView.element;
      });
    })));

    //Rightbar
    final List<model.OrganizationReference> oRefs = (await _contactController
            .contactOrganizations(cid))
        .toList(growable: false)..sort(view.compareOrgRefs);

    _ulOrganizationList.children =
        new List.from(oRefs.map(_createOrganizationNode));

    final List<model.ContactReference> collRefs =
        (await _contactController.colleagues(cid)).toList(growable: false)
          ..sort(view.compareContactRefs);

    _ulReceptionList.children = collRefs.map(_createColleagueNode).toList();
  }

  Future _receptionContactUpdate(model.ReceptionAttributes ca) {
    return _contactController.updateInReception(ca).then((_) {
      notify.success('Oplysningerne blev gemt', '');
    }).catchError((error, stack) {
      notify.error('Ændringerne blev ikke gemt', 'Fejl: $error');
      _log.severe('Tried to update a Reception Contact, '
          'but failed with "${error}", ${stack}');
    });
  }

  Future _receptionContactCreate(model.ReceptionAttributes attr) {
    return _contactController.addToReception(attr).then((_) {
      notify.success('Tilføjet til reception',
          '${attr.reference.reception.name} til (rid: ${attr.receptionId})');
      bus.fire(
          new ReceptionContactAddedEvent(attr.receptionId, attr.contactId));
    }).catchError((error, stack) {
      notify.error(
          'Kunne ikke tilføje kontakt til reception', 'Fejl: ${error}');
      _log.severe(
          'Tried to update a Reception Contact, but failed with "$error" ${stack}');
    });
  }

  /**
   * Clear our the fields of the view and hide the relevant DOM nodes.
   */
  void _clearContent() {
    _contactData.clear();
    _ulOrganizationList.children.clear();
    _ulReceptionData.children.clear();
    _ulReceptionList.children.clear();
    _contactData.element.hidden = true;
  }

  /**
   *
   */
  LIElement _createReceptionNode(model.Reception reception) {
    // First node is the receptionname. Clickable to the reception
    //   Second node is a list of contacts in that reception. Could make it lazy loading with a little plus, that "expands" (Fetches the data) the list
    LIElement rootNode = new LIElement();
    HeadingElement receptionNode = new HeadingElement.h4()
      ..classes.add('clickable')
      ..text = reception.name
      ..onClick.listen((_) {
        Map data = {
          'organization_id': reception.organizationId,
          'reception_id': reception.id
        };
        bus.fire(new WindowChanged('reception', data));
      });

    UListElement contactsUl = new UListElement()..classes.add('zebra-odd');

    _contactController
        .receptionContacts(reception.id)
        .then((Iterable<model.ContactReference> cRefs) {
      contactsUl.children = cRefs
          .map((model.ContactReference collegue) =>
              _createColleagueNode(collegue))
          .toList();
    });

    rootNode.children.addAll([receptionNode, contactsUl]);
    return rootNode;
  }

  /**
   * TODO: Add reception references
   */
  LIElement _createColleagueNode(model.ContactReference collegue) {
    return new LIElement()
      ..classes.add('clickable')
      ..classes.add('colleague')
      ..text = '${collegue.name}'
      ..onClick.listen((_) {
        Map data = {'contact_id': collegue.id};
        bus.fire(new WindowChanged('contact', data));
      });
  }

  /**
   *
   */
  LIElement _createOrganizationNode(model.OrganizationReference oref) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${oref.name}'
      ..onClick.listen((_) {
        Map data = {'organization_id': oref.id,};
        bus.fire(new WindowChanged('organization', data));
      });
    return li;
  }
}
