library contact.view;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';

import 'package:management_tool/eventbus.dart';
import 'package:management_tool/view.dart' as view;

import 'package:management_tool/searchcomponent.dart';
import 'package:management_tool/configuration.dart';
import 'package:openreception_framework/model.dart' as model;
import 'package:openreception_framework/storage.dart' as storage;

import 'package:management_tool/controller.dart' as controller;

const String _libraryName = 'contact.view';

controller.Popup notify = controller.popup;

class ContactView {
  static const String _viewName = 'contact';
  final Logger _log = new Logger('$_libraryName.Contact');
  DivElement element;

  final controller.Contact _contactController;
  final controller.Calendar _calendarController;
  final controller.Organization _organizationController;
  final controller.Reception _receptionController;
  final controller.DistributionList _dlistController;
  final controller.Endpoint _endpointController;

  UListElement _ulContactList;
  UListElement _ulReceptionContacts;
  UListElement _ulReceptionList;
  UListElement _ulOrganizationList;
  List<model.BaseContact> _contactList = new List<model.BaseContact>();
  SearchInputElement _searchBox;

  view.Calendar _calendarView;
  view.Calendar _deletedCalendarView;

  final TextInputElement _nameInput = new TextInputElement()
    ..id = 'contact-input-name'
    ..classes.add('wide');

  final NumberInputElement _importCidInput = new NumberInputElement()
    ..style.width = '50%'
    ..placeholder = 'Kontakt ID at importere fra';
  final ButtonElement _importButton = new ButtonElement()
    ..classes.add('create')
    ..text = 'Importer';

  final HiddenInputElement _bcidInput = new HiddenInputElement()
    ..value = model.Contact.noID.toString();

  final SelectElement _typeInput = new SelectElement();
  final HeadingElement _header = new HeadingElement.h2();
  final CheckboxInputElement _enabledInput = new CheckboxInputElement()
    ..id = 'contact-input-enabled';

  DivElement get _baseInfoContainer =>
      element.querySelector('#contact-base-info')
        ..id = 'contact-base-info'
        ..hidden = true;

  final ButtonElement _createButton = new ButtonElement()
    ..id = 'contact-create'
    ..text = 'Opret'
    ..classes.add('create');

  final ButtonElement _joinReceptionbutton = new ButtonElement()
    ..text = 'Tilføj'
    ..id = 'contact-add';

  final ButtonElement _saveButton = new ButtonElement()
    ..text = 'Gem'
    ..classes.add('save');

  final ButtonElement _deleteButton = new ButtonElement()
    ..text = 'Slet'
    ..classes.add('delete');

  final AnchorElement _calendarToggle = new AnchorElement()
    ..href = '#calendar'
    ..text = 'Vis kalenderaftaler';

  final DivElement _receptionOuterSelector = new DivElement()
    ..id = 'contact-reception-selector';

  final DivElement _calendarsContainer = new DivElement()..style.clear = 'both';

  SearchComponent<model.Reception> _search;
  bool createNew = false;

  static const List<String> phonenumberTypes = const ['PSTN', 'SIP'];

  ContactView(
      DivElement this.element,
      this._contactController,
      this._organizationController,
      this._receptionController,
      this._calendarController,
      this._dlistController,
      this._endpointController) {
    _baseInfoContainer.children = [
      _deleteButton,
      _saveButton,
      _header,
      _bcidInput,
      new DivElement()
        ..classes.add('col-1-2')
        ..children = [
          new DivElement()
            ..children = [new LabelElement()..text = 'Aktiv', _enabledInput],
          new DivElement()
            ..children = [new LabelElement()..text = 'Navn', _nameInput],
          new DivElement()
            ..children = [
              new LabelElement()..text = 'Importer receptioner fra kontakt',
              _importCidInput,
              _importButton
            ],
        ],
      new DivElement()
        ..classes.add('col-1-2')
        ..children = [
          new DivElement()
            ..children = [new LabelElement()..text = 'Type', _typeInput],
          new LabelElement()..text = 'Tilføj til Reception:',
          _receptionOuterSelector,
          _joinReceptionbutton
        ],
      new DivElement()
        ..style.clear = 'both'
        ..children = [_calendarToggle]
    ];

    _calendarView = new view.Calendar(_calendarController, false);
    _deletedCalendarView = new view.Calendar(_calendarController, true);

    element.querySelector('#contact-create').replaceWith(_createButton);

    _ulContactList = element.querySelector('#contact-list');
    element.classes.add('page');

    _calendarsContainer
      ..children = [
        new HeadingElement.h4()..text = 'Kalender',
        _calendarView.element,
        new HeadingElement.h4()..text = 'Slettede KalenderPoster',
        _deletedCalendarView.element
      ];

    _calendarToggle.onClick.listen((_) {
      _calendarsContainer.hidden = !_calendarsContainer.hidden;

      _calendarToggle.text = _calendarsContainer.hidden
          ? 'Vis kalenderaftaler'
          : 'Skjul kalenderaftaler';
    });

    _baseInfoContainer.children.add(_calendarsContainer);

    _ulReceptionContacts = element.querySelector('#reception-contacts');
    _ulReceptionList = element.querySelector('#contact-reception-list');
    _ulOrganizationList = element.querySelector('#contact-organization-list');

    _searchBox = element.querySelector('#contact-search-box');

    _search = new SearchComponent<model.Reception>(
        _receptionOuterSelector, 'contact-reception-searchbox')
      ..listElementToString = _receptionToSearchboxString
      ..searchFilter = _receptionSearchHandler
      ..searchPlaceholder = 'Søg...';

    _fillSearchComponent();

    _observers();

    _refreshList();

    _typeInput.children.addAll(model.ContactType.types
        .map((type) => new OptionElement(data: type, value: type)));
  }

  String _receptionToSearchboxString(
      model.Reception reception, String searchterm) {
    return '${reception.fullName}';
  }

  bool _receptionSearchHandler(model.Reception reception, String searchTerm) {
    return reception.fullName.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void set baseContact(model.BaseContact bc) {
    _nameInput.value = bc.fullName;
    _typeInput.options.forEach((OptionElement option) =>
        option.selected = option.value == bc.contactType);
    _enabledInput.checked = bc.enabled;

    _importButton.text = 'Importer';
    _importCidInput.value = '';
    _deleteButton.text = 'Slet';
    _bcidInput.value = bc.id.toString();

    _calendarsContainer..hidden = true;
    _calendarToggle..text = 'Vis kalenderaftaler';

    if (bc.id != model.Contact.noID) {
      _activateContact(bc.id);
      _saveButton.disabled = true;
      _header.text = 'Retter basisinfo for ${bc.fullName} (cid: ${bc.id})';
    } else {
      _header.text = 'Opret ny basiskontakt';

      _saveButton.disabled = false;
      _ulReceptionList.children = [];
      _ulOrganizationList.children = [];
      _ulReceptionContacts.children = [];
    }

    _deleteButton.disabled = !_saveButton.disabled;
    _baseInfoContainer.hidden = false;
  }

  model.BaseContact get baseContact => new model.BaseContact.empty()
    ..id = int.parse(_bcidInput.value)
    ..enabled = _enabledInput.checked
    ..contactType = _typeInput.value
    ..fullName = _nameInput.value;

  /**
   *
   */
  void _observers() {
    _nameInput.onInput.listen((_) {
      _saveButton.disabled = false;
      _deleteButton.disabled = !_saveButton.disabled;
    });

    _enabledInput.onChange.listen((_) {
      _saveButton.disabled = false;
      _deleteButton.disabled = !_saveButton.disabled;
    });

    _typeInput.onChange.listen((_) {
      _saveButton.disabled = false;
      _deleteButton.disabled = !_saveButton.disabled;
    });

    _importCidInput.onInput.listen((_) {
      _saveButton.disabled = true;
      _deleteButton.disabled = true;
    });

    _calendarView.onDelete = () async {
      _calendarController
          .listContact(baseContact.id, deleted: false)
          .then((Iterable<model.CalendarEntry> entries) {
        _calendarView.entries = entries;
      });

      _calendarController
          .listContact(baseContact.id, deleted: true)
          .then((Iterable<model.CalendarEntry> entries) {
        _deletedCalendarView.entries = entries;
      });
    };

    _deletedCalendarView.onDelete = () async {
      _calendarController
          .listContact(baseContact.id, deleted: false)
          .then((Iterable<model.CalendarEntry> entries) {
        _calendarView.entries = entries;
      });

      _calendarController
          .listContact(baseContact.id, deleted: true)
          .then((Iterable<model.CalendarEntry> entries) {
        _deletedCalendarView.entries = entries;
      });
    };

    _saveButton.onClick.listen((_) async {
      model.BaseContact updated;
      if (baseContact.id == model.Contact.noID) {
        updated = await _contactController.create(baseContact);
        notify.success('Oprettede kontaktperson', '${updated.fullName}');
      } else {
        updated = await _contactController.update(baseContact);
        notify.success('Opdaterede kontaktperson', '${updated.fullName}');
      }
      _saveButton.disabled = false;
      _deleteButton.disabled = !_saveButton.disabled;
      await _refreshList();
      baseContact = await _contactController.get(updated.id);
    });

    _importButton.onClick.listen((_) async {
      int sourceCid;
      final String confirmationText =
          'Bekræft import (slet cid:${_importCidInput.value})';

      if (_importCidInput.value.isEmpty) {
        return;
      }

      if (_importButton.text != confirmationText) {
        _importButton.text = confirmationText;
        _saveButton.disabled = true;
        _deleteButton.disabled = true;
      } else {
        try {
          sourceCid = int.parse(_importCidInput.value);

          if (sourceCid == baseContact.id) {
            notify.error('"${_importCidInput.value}" er egen ID', '');
            return;
          }
        } on FormatException {
          notify.error('"${_importCidInput.value}" er ikke et tal', '');
          return;
        }

        try {
          final int dcid = baseContact.id;
          final List<int> rids = await _contactController.receptions(sourceCid);

          await Future.wait(rids.map((int rid) async {
            final model.Contact contactData =
                await _contactController.getByReception(sourceCid, rid);
            contactData.ID = dcid;
            await _contactController.addToReception(contactData, rid);

            /// Import endpoints
            Iterable<model.MessageEndpoint> endpoints =
                await _endpointController.list(rid, sourceCid);

            _log.finest('Found endpoints: ${endpoints.join(', ')}');

            await Future.wait(endpoints.map((mep) async {
              _log.finest('Adding endpoint $mep to cid:$dcid');
              mep.id = model.MessageEndpoint.noId;
              await _endpointController.create(rid, dcid, mep);
            }));

            /// Import distribution list
            model.DistributionList dlist =
                await _dlistController.list(rid, sourceCid);

            _log.finest('Found distribution list : ${dlist.join(', ')}');

            await Future.wait(dlist.map((dle) async {
              dle.id = model.DistributionListEntry.noId;
              if (dle.contactID == sourceCid) {
                dle.contactID = dcid;
              }

              _log.finest('Adding dlist entry ${dle.toJson()} to cid:$dcid');
              await _dlistController.addRecipient(rid, dcid, dle);
            }));
          }));

          /// Import calender entries
          final Iterable<model.CalendarEntry> entries =
              await _calendarController.listContact(sourceCid);

          _log.finest('Found calendar list : ${entries.join(', ')}');

          await Future.wait(entries.map((ce) async {
            ce
              ..ID = model.CalendarEntry.noID
              ..owner = new model.OwningContact(dcid);

            _log.finest('Adding calendar entry ${ce.toJson()} to cid:$dcid');

            await _calendarController.create(ce, config.user);
          }));

          _log.finest('Deleting cid:$sourceCid');
          await _contactController.remove(sourceCid);

          notify.success(
              'Tilføjede ${baseContact.fullName} til ${rids.length} receptioner',
              '');

          _refreshList();
          baseContact = await _contactController.get(dcid);
        } on storage.NotFound {
          notify.error('cid:${sourceCid} Findes ikke', '');

          return;
        }
      }
    });

    bus.on(WindowChanged).listen((WindowChanged event) async {
      element.classes.toggle('hidden', event.window != _viewName);
      if (event.data.containsKey('contact_id')) {
        baseContact = await _contactController.get(event.data['contact_id']);
      }
    });

    bus.on(ReceptionAddedEvent).listen((_) {
      _fillSearchComponent();
    });

    bus.on(ReceptionRemovedEvent).listen((_) {
      _fillSearchComponent();
    });

    _createButton.onClick.listen((_) {
      baseContact = new model.BaseContact.empty();
    });
    _joinReceptionbutton.onClick.listen((_) => _addReceptionToContact());
    _deleteButton.onClick.listen((_) => _deleteSelectedContact());
    _searchBox.onInput.listen((_) => _performSearch());
  }

  void _refreshList() {
    _contactController.listAll().then((Iterable<model.BaseContact> contacts) {
      int compareTo(model.BaseContact c1, model.BaseContact c2) =>
          c1.fullName.compareTo(c2.fullName);

      List<model.BaseContact> list = contacts.toList()..sort(compareTo);
      this._contactList = list;
      _performSearch();
    }).catchError((error) {
      _log.severe('Tried to fetch organization but got error: $error');
    });
  }

  void _performSearch() {
    String searchTerm = _searchBox.value;
    _ulContactList.children
      ..clear()
      ..addAll(_contactList
          .where((model.BaseContact contact) =>
              contact.fullName.toLowerCase().contains(searchTerm.toLowerCase()))
          .map(_makeContactNode));
  }

  LIElement _makeContactNode(model.BaseContact contact) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${contact.fullName}'
      ..dataset['contactid'] = '${contact.id}'
      ..onClick.listen((_) {
        baseContact = contact;
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
  void _activateContact(int id, [int reception_id]) {
    _contactController.get(id).then((model.BaseContact contact) {
      _joinReceptionbutton.disabled = false;
      createNew = false;

      _nameInput.value = contact.fullName;
      _typeInput.options.forEach((OptionElement option) =>
          option.selected = option.value == contact.contactType);
      _enabledInput.checked = contact.enabled;
      _header.text = 'Basisinfo for ${contact.fullName} (cid: ${contact.id})';

      _highlightContactInList(id);

      _calendarController
          .listContact(contact.id, deleted: false)
          .then((Iterable<model.CalendarEntry> entries) {
        _calendarView.entries = entries;
      });

      _calendarController
          .listContact(contact.id, deleted: true)
          .then((Iterable<model.CalendarEntry> entries) {
        _deletedCalendarView.entries = entries;
      });

      return _contactController
          .receptions(id)
          .then((Iterable<int> receptionIDs) {
        _ulReceptionContacts.children = [];
        Future.forEach(receptionIDs, (int receptionID) {
          _contactController
              .getByReception(id, receptionID)
              .then((model.Contact contact) {
            view.ReceptionContact rcView = new view.ReceptionContact(
                _receptionController,
                _contactController,
                _endpointController,
                _dlistController)..contact = contact;

            _ulReceptionContacts.children.add(rcView.element);
          });
        });

        //Rightbar
        _contactController
            .contactOrganizations(id)
            .then((Iterable<int> organizationsIDs) {
          _ulOrganizationList.children..clear();

          Future.forEach(organizationsIDs, (int organizationID) {
            _organizationController
                .get(organizationID)
                .then((model.Organization org) {
              _ulOrganizationList.children.add(_createOrganizationNode(org));
            });
          });
        }).catchError((error, stack) {
          _log.severe(
              'Tried to update contact "${id}"s rightbar but got "${error}" \n${stack}');
        });

        //FIXME: Figure out how this should look.
        return _contactController
            .colleagues(id)
            .then((Iterable<model.Contact> contacts) {
          int compareTo(model.Contact c1, model.Contact c2) =>
              c1.fullName.toLowerCase().compareTo(c2.fullName.toLowerCase());

          List list = contacts.toList()..sort(compareTo);

          _ulReceptionList.children = list.map(_createColleagueNode).toList();
        });
      });
    }).catchError((error, stack) {
      _log.severe(
          'Tried to activate contact "${id}" but gave "${error}" \n${stack}');
    });
  }

  void _fillSearchComponent() {
    _receptionController.list().then((Iterable<model.Reception> receptions) {
      int compareTo(model.Reception rs1, model.Reception rs2) =>
          rs1.fullName.compareTo(rs2.fullName);

      List list = receptions.toList()..sort(compareTo);

      _search.updateSourceList(list);
    });
  }

  Future _receptionContactUpdate(model.Contact ca) {
    return _contactController.updateInReception(ca).then((_) {
      notify.success('Oplysningerne blev gemt', '');
    }).catchError((error, stack) {
      notify.error('Ændringerne blev ikke gemt', 'Fejl: $error');
      _log.severe('Tried to update a Reception Contact, '
          'but failed with "${error}", ${stack}');
    });
  }

  Future _receptionContactCreate(model.Contact contact) {
    return _contactController
        .addToReception(contact, contact.receptionID)
        .then((_) {
      notify.success('Tilføjet til reception',
          '${contact.fullName} til (rid: ${contact.receptionID})');
      bus.fire(new ReceptionContactAddedEvent(contact.receptionID, contact.ID));
    }).catchError((error, stack) {
      notify.error(
          'Kunne ikke tilføje kontakt til reception', 'Fejl: ${error}');
      _log.severe(
          'Tried to update a Reception Contact, but failed with "$error" ${stack}');
    });
  }

  /**
   *
   */
  void _clearContent() {
    _nameInput.value = '';
    _typeInput.selectedIndex = 0;
    _enabledInput.checked = true;
    _ulReceptionContacts.children.clear();
  }

  /**
   *
   */
  void _addReceptionToContact() {
    if (_search.currentElement != null && int.parse(_bcidInput.value) > 0) {
      model.Reception reception = _search.currentElement;

      model.Contact template = new model.Contact.empty()
        ..receptionID = reception.ID
        ..ID = int.parse(_bcidInput.value);

      _contactController
          .addToReception(template, reception.ID)
          .then((model.Contact createdContact) {
        view.ReceptionContact rcView = new view.ReceptionContact(
            _receptionController,
            _contactController,
            _endpointController,
            _dlistController)..contact = template;

        _ulReceptionContacts.children..add(rcView.element);
        notify.success('Tilføjede kontaktperson til reception',
            '${baseContact.fullName} til ${reception.name}');
      }).catchError((e) {
        notify.error(
            'Kunne ikke tilføje kontaktperson til reception', 'Fejl: ${e}');
      });
    }
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
      ..text = reception.fullName
      ..onClick.listen((_) {
        Map data = {
          'organization_id': reception.organizationId,
          'reception_id': reception.ID
        };
        bus.fire(new WindowChanged('reception', data));
      });

    UListElement contactsUl = new UListElement()..classes.add('zebra-odd');

    _contactController
        .list(reception.ID)
        .then((Iterable<model.Contact> contacts) {
      contactsUl.children = contacts
          .map((model.Contact collegue) => _createColleagueNode(collegue))
          .toList();
    });

    rootNode.children.addAll([receptionNode, contactsUl]);
    return rootNode;
  }

  /**
   * TODO: Add reception Name.
   */
  LIElement _createColleagueNode(model.Contact collegue) {
    return new LIElement()
      ..classes.add('clickable')
      ..classes.add('colleague')
      ..text = '${collegue.fullName} (rid: ${collegue.receptionID})'
      ..onClick.listen((_) {
        Map data = {
          'contact_id': collegue.ID,
          'reception_id': collegue.receptionID
        };
        bus.fire(new WindowChanged('contact', data));
      });
  }

  /**
   *
   */
  LIElement _createOrganizationNode(model.Organization organization) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${organization.fullName}'
      ..onClick.listen((_) {
        Map data = {'organization_id': organization.id,};
        bus.fire(new WindowChanged('organization', data));
      });
    return li;
  }

  /**
   *
   */
  Future _deleteSelectedContact() async {
    _log.finest('Deleting baseContact cid${baseContact.id}');
    final String confirmationText =
        'Bekræft sletning af cid: ${baseContact.id}?';

    if (_deleteButton.text != confirmationText) {
      _deleteButton.text = confirmationText;
      return;
    }

    try {
      _deleteButton.disabled = true;

      await _contactController.remove(baseContact.id);
      notify.success('Kontaktperson slettet', baseContact.fullName);
      _baseInfoContainer.hidden = true;
      _refreshList();
      _clearContent();
      _joinReceptionbutton.disabled = true;
      baseContact = new model.BaseContact.empty();
    } catch (error) {
      notify.error('Kunne ikke slette kontaktperson', baseContact.fullName);
      _log.severe('Delete baseContact failed with: ${error}');
    }

    _deleteButton.text = 'Slet';
  }
}
