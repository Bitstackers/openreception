library contact.view;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:route_hierarchical/client.dart';

import 'package:management_tool/view.dart' as view;

import 'package:management_tool/searchcomponent.dart';
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/storage.dart' as storage;

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
  final Router _router;

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
    ..value = model.BaseContact.noId.toString();

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

  SearchComponent<model.ReceptionReference> _search;
  bool createNew = false;

  static const List<String> phonenumberTypes = const ['PSTN', 'SIP'];

  ContactView(
      DivElement this.element,
      this._contactController,
      this._organizationController,
      this._receptionController,
      this._calendarController,
      this._router) {
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

    _calendarView = new view.Calendar(
        _calendarController, new model.OwningContact(model.BaseContact.noId));
    _deletedCalendarView = new view.Calendar(
        _calendarController, new model.OwningContact(model.BaseContact.noId));

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

    _search = new SearchComponent<model.ReceptionReference>(
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
      model.ReceptionReference reception, String searchterm) {
    return '${reception.name}';
  }

  bool _receptionSearchHandler(
      model.ReceptionReference reception, String searchTerm) {
    return reception.name.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void set baseContact(model.BaseContact bc) {
    _nameInput.value = bc.name;
    _typeInput.options.forEach(
        (OptionElement option) => option.selected = option.value == bc.type);
    _enabledInput.checked = bc.enabled;

    _importButton.text = 'Importer';
    _importCidInput.value = '';
    _deleteButton.text = 'Slet';
    _bcidInput.value = bc.id.toString();

    _calendarsContainer..hidden = true;
    _calendarToggle..text = 'Vis kalenderaftaler';

    if (bc.id != model.BaseContact.noId) {
      _activateContact(bc.id);
      _saveButton.disabled = true;
      _header.text = 'Retter basisinfo for ${bc.name} (cid: ${bc.id})';
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
    ..type = _typeInput.value
    ..name = _nameInput.value;

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
          .listContact(baseContact.id)
          .then((Iterable<model.CalendarEntry> entries) {
        _calendarView.entries = entries;
      });

      _calendarController
          .listContact(baseContact.id)
          .then((Iterable<model.CalendarEntry> entries) {
        _deletedCalendarView.entries = entries;
      });
    };

    _deletedCalendarView.onDelete = () async {
      _calendarController
          .listContact(baseContact.id)
          .then((Iterable<model.CalendarEntry> entries) {
        _calendarView.entries = entries;
      });

      _calendarController
          .listContact(baseContact.id)
          .then((Iterable<model.CalendarEntry> entries) {
        _deletedCalendarView.entries = entries;
      });
    };

    _saveButton.onClick.listen((_) async {
      model.BaseContact updated;
      if (baseContact.id == model.BaseContact.noId) {
        updated = await _contactController.create(baseContact);
        notify.success('Oprettede kontaktperson', '${updated.name}');
      } else {
        updated = await _contactController.update(baseContact);
        notify.success('Opdaterede kontaktperson', '${updated.name}');
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
          final List<model.ReceptionReference> rRefs =
              await _contactController.receptions(sourceCid);

          await Future.wait(rRefs.map((model.ReceptionReference rRef) async {
            final model.ReceptionAttributes contactData =
                await _contactController.getByReception(sourceCid, rRef.id);
            contactData.cid = dcid;
            contactData.receptionId = rRef.id;
            await _contactController.addToReception(contactData);
          }));

          /// Import calender entries
          final Iterable<model.CalendarEntry> entries =
              await _calendarController.listContact(sourceCid);

          _log.finest('Found calendar list : ${entries.join(', ')}');

          await Future.wait(entries.map((ce) async {
            ce
              ..id = model.CalendarEntry.noId
              ..owner = new model.OwningContact(dcid);

            _log.finest('Adding calendar entry ${ce.toJson()} to cid:$dcid');

            await _calendarController.create(ce);
          }));

          _log.finest('Deleting cid:$sourceCid');
          await _contactController.remove(sourceCid);

          notify.success(
              'Tilføjede ${baseContact.name} til ${rRefs.length} receptioner',
              '');

          _refreshList();
          baseContact = await _contactController.get(dcid);
        } on storage.NotFound {
          notify.error('cid:${sourceCid} Findes ikke', '');

          return;
        }
      }
    });

    _createButton.onClick.listen((_) {
      baseContact = new model.BaseContact.empty();
    });
    _joinReceptionbutton.onClick.listen((_) => _addReceptionToContact());
    _deleteButton.onClick.listen((_) => _deleteSelectedContact());
    _searchBox.onInput.listen((_) => _performSearch());
  }

  void _refreshList() {
    _contactController.list().then((Iterable<model.BaseContact> contacts) {
      int compareTo(model.BaseContact c1, model.BaseContact c2) =>
          c1.name.compareTo(c2.name);

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
              contact.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .map(_makeContactNode));
  }

  /**
   * TODO: Add ⚙ for function persons.
   */
  LIElement _makeContactNode(model.BaseContact cRef) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = cRef.name
      ..dataset['contactid'] = '${cRef.id}'
      ..onClick.listen((_) async {
        baseContact = await _contactController.get(cRef.id);
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
  Future _activateContact(int id, [int receptionId]) async {
    final model.BaseContact contact = await _contactController.get(id);
    _joinReceptionbutton.disabled = false;
    createNew = false;

    _nameInput.value = contact.name;
    _typeInput.options.forEach((OptionElement option) =>
        option.selected = option.value == contact.type);
    _enabledInput.checked = contact.enabled;
    _header.text = 'Basisinfo for ${contact.name} (cid: ${contact.id})';

    _highlightContactInList(id);

    _calendarView.entries = await _calendarController.listContact(contact.id);

    //TODO: change to show history
    // await _calendarController
    //     .listContact(contact.id)
    //     .then((Iterable<model.CalendarEntry> entries) {
    //   _deletedCalendarView.entries = entries;
    // });

    final Iterable<model.ReceptionReference> rRefs =
        await _contactController.receptions(id);

    _ulReceptionContacts.children = [];
    await Future.forEach(rRefs, (model.ReceptionReference rRef) async {
      view.ReceptionContact rcView = new view.ReceptionContact(
          _receptionController, _contactController, rRefs.length == 1)
        ..attributes = await _contactController.getByReception(id, rRef.id);

      _ulReceptionContacts.children.add(rcView.element);
    });

    //FIXME: Re-enable this somehow.
    // await _contactController
    //     .colleagues(id)
    //     .then((Iterable<model.ContactReference> contacts) {
    //   int nameSort(model.ContactReference x, model.ContactReference y) =>
    //       x.name.toLowerCase().compareTo(y.name.toLowerCase());
    //   final List<model.ContactReference> functionContacts = contacts
    //       .where((model.ContactReference contact) =>
    //           contact.enabled && contact.contactType == 'function')
    //       .toList()..sort(nameSort);
    //   final List<model.Contact> humanContacts = contacts
    //       .where((model.Contact contact) =>
    //           contact.enabled && contact.contactType == 'human')
    //       .toList()..sort(nameSort);
    //   final List<model.Contact> disabledContacts = contacts
    //       .where((model.Contact contact) => !contact.enabled)
    //       .toList()..sort(nameSort);
    //
    //   List<model.ContactReference> sorted =
    //       new List<model.ContactReference>()
    //         ..addAll(functionContacts)
    //         ..addAll(humanContacts)
    //         ..addAll(disabledContacts);
    //
    //   List<model.ContactReference> sorted = contacts.toList(growable: false)
    //     ..sort(nameSort);
    //
    //   _ulReceptionList.children = sorted.map(_createColleagueNode).toList();
    // });
  }

  void _fillSearchComponent() {
    _receptionController
        .list()
        .then((Iterable<model.ReceptionReference> rRefs) {
      int compareTo(
              model.ReceptionReference rs1, model.ReceptionReference rs2) =>
          rs1.name.compareTo(rs2.name);

      List list = rRefs.toList()..sort(compareTo);

      _search.updateSourceList(list);
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
      model.ReceptionReference rRef = _search.currentElement;

      model.ReceptionAttributes template = new model.ReceptionAttributes.empty()
        ..receptionId = rRef.id
        ..cid = int.parse(_bcidInput.value);

      _contactController
          .addToReception(template)
          .then((model.ReceptionContact rcRef) {
        view.ReceptionContact rcView = new view.ReceptionContact(
            _receptionController, _contactController, true)
          ..attributes = template;

        _ulReceptionContacts.children..add(rcView.element);
        notify.success('Tilføjede kontaktperson til reception',
            '${baseContact.name} til ${rRef.name}');
      }).catchError((e) {
        notify.error(
            'Kunne ikke tilføje kontaktperson til reception', 'Fejl: ${e}');
      });
    }
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
      notify.success('Kontaktperson slettet', baseContact.name);
      _baseInfoContainer.hidden = true;
      _refreshList();
      _clearContent();
      _joinReceptionbutton.disabled = true;
      baseContact = new model.BaseContact.empty();
    } catch (error) {
      notify.error('Kunne ikke slette kontaktperson', baseContact.name);
      _log.severe('Delete baseContact failed with: ${error}');
    }

    _deleteButton.text = 'Slet';
  }
}
