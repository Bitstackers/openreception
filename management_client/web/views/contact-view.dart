library contact.view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:html5_dnd/html5_dnd.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../lib/configuration.dart';
import '../lib/eventbus.dart';
import '../lib/logger.dart' as log;
import '../notification.dart' as notify;
import '../lib/searchcomponent.dart';
import '../lib/view_utilities.dart';
import '../menu.dart';
import 'package:openreception_framework/model.dart' as ORModel;
import '../lib/controller.dart' as Controller;
import 'package:logging/logging.dart';

part 'components/contact_calendar.dart';
part 'components/distributionlist.dart';
part 'components/endpoint.dart';

typedef Future HandleReceptionContact(ORModel.Contact receptionContact);
typedef Future LazyFuture();

const String _libraryName = 'contact.view';

class ContactView {
  static const String viewName = 'contact';
  DivElement element;

  final Controller.Contact _contactController;
  final Controller.Calendar _calendarController;
  final Controller.Organization _organizationController;
  final Controller.Reception _receptionController;
  final Controller.DistributionList _dlistController;
  final Controller.Endpoint _endpointController;


  UListElement ulContactList;
  UListElement ulReceptionContacts;
  UListElement ulReceptionList;
  UListElement ulOrganizationList;
  List<ORModel.BaseContact> contactList = new List<ORModel.BaseContact>();
  SearchInputElement searchBox;

  TextAreaElement inputName;
  SelectElement inputType;
  SpanElement spanContactId;
  CheckboxInputElement inputEnabled;

  ButtonElement buttonSave, buttonCreate, buttonDelete, buttonJoinReception;
  DivElement receptionOuterSelector;

  SearchComponent<ORModel.Reception> SC;
  int selectedContactId;
  bool createNew = false;

  Map<int, LazyFuture> saveList = new Map<int, LazyFuture>();
  static const List<String> phonenumberTypes = const ['PSTN', 'SIP'];

  ContactView(DivElement this.element, this._contactController,
      this._organizationController, this._receptionController,
      this._calendarController, this._dlistController, this._endpointController) {
    ulContactList = element.querySelector('#contact-list');

    inputName = element.querySelector('#contact-input-name');
    inputType = element.querySelector('#contact-select-type');
    inputEnabled = element.querySelector('#contact-input-enabled');
    spanContactId = element.querySelector('#contact-span-id');
    ulReceptionContacts = element.querySelector('#reception-contacts');
    ulReceptionList = element.querySelector('#contact-reception-list');
    ulOrganizationList = element.querySelector('#contact-organization-list');

    buttonSave = element.querySelector('#contact-save');
    buttonCreate = element.querySelector('#contact-create');
    buttonDelete = element.querySelector('#contact-delete');
    buttonJoinReception = element.querySelector('#contact-add');
    searchBox = element.querySelector('#contact-search-box');
    receptionOuterSelector =
        element.querySelector('#contact-reception-selector');

    SC = new SearchComponent<ORModel.Reception>(
        receptionOuterSelector, 'contact-reception-searchbox')
      ..listElementToString = receptionToSearchboxString
      ..searchFilter = receptionSearchHandler
      ..searchPlaceholder = 'Søg...';

    fillSearchComponent();

    registrateEventHandlers();

    refreshList();

    inputType.children.addAll(ORModel.ContactType.types
        .map((type) => new OptionElement(data: type, value: type)));
  }

  String receptionToSearchboxString(
      ORModel.Reception reception, String searchterm) {
    return '${reception.fullName}';
  }

  bool receptionSearchHandler(ORModel.Reception reception, String searchTerm) {
    return reception.fullName.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void registrateEventHandlers() {
    bus.on(WindowChanged).listen((WindowChanged event) {
      element.classes.toggle('hidden', event.window != viewName);
      if (event.data.containsKey('contact_id')) {
        activateContact(event.data['contact_id'], event.data['reception_id']);
      }
    });

    bus.on(ReceptionAddedEvent).listen((_) {
      fillSearchComponent();
    });

    bus.on(ReceptionRemovedEvent).listen((_) {
      fillSearchComponent();
    });

    buttonSave.onClick.listen((_) => saveChanges());
    buttonCreate.onClick.listen((_) => createContact());
    buttonJoinReception.onClick.listen((_) => addReceptionToContact());
    buttonDelete.onClick.listen((_) => deleteSelectedContact());
    searchBox.onInput.listen((_) => performSearch());
  }

  void refreshList() {
    _contactController.listAll().then((Iterable<ORModel.BaseContact> contacts) {
      int compareTo(ORModel.BaseContact c1, ORModel.BaseContact c2) =>
          c1.fullName.compareTo(c2.fullName);

      List<ORModel.BaseContact> list = contacts.toList()..sort(compareTo);
      this.contactList = list;
      performSearch();
    }).catchError((error) {
      log.error('Tried to fetch organization but got error: $error');
    });
  }

  void performSearch() {
    String searchTerm = searchBox.value;
    ulContactList.children
      ..clear()
      ..addAll(contactList
          .where((ORModel.BaseContact contact) =>
              contact.fullName.toLowerCase().contains(searchTerm.toLowerCase()))
          .map(makeContactNode));
  }

  LIElement makeContactNode(ORModel.BaseContact contact) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${contact.fullName}'
      ..dataset['contactid'] = '${contact.id}'
      ..onClick.listen((_) => activateContact(contact.id));
    return li;
  }

  void highlightContactInList(int id) {
    ulContactList.children.forEach((LIElement li) => li.classes.toggle(
        'highlightListItem', li.dataset['contactid'] == '$id'));
  }

  void activateContact(int id, [int reception_id]) {
    _contactController.get(id).then((ORModel.BaseContact contact) {
      buttonSave.text = 'Gem';
      buttonSave.disabled = false;
      buttonDelete.disabled = false;
      buttonJoinReception.disabled = false;
      createNew = false;

      inputName.value = contact.fullName;
      inputType.options.forEach((OptionElement option) =>
          option.selected = option.value == contact.contactType);
      inputEnabled.checked = contact.enabled;
      spanContactId.text = '${contact.id}';
      selectedContactId = contact.id;

      highlightContactInList(id);

      return _contactController
          .receptions(id)
          .then((Iterable<int> receptionIDs) {
        ulReceptionContacts.children = [];
        Future.forEach(receptionIDs, (int receptionID) {
          _contactController
              .getByReception(id, receptionID)
              .then((ORModel.Contact contact) {
            saveList.clear();
            ulReceptionContacts.children.add(receptionContactBox(contact));
          });
        });

        //Rightbar
        _contactController
            .contactOrganizations(id)
            .then((Iterable<int> organizationsIDs) {
          ulOrganizationList.children..clear();

          Future.forEach(organizationsIDs, (int organizationID) {
            _organizationController
                .get(organizationID)
                .then((ORModel.Organization org) {
              saveList.clear();
              ulOrganizationList.children.add(createOrganizationNode(org));
            });
          });
        }).catchError((error, stack) {
          log.error(
              'Tried to update contact "${id}"s rightbar but got "${error}" \n${stack}');
        });

        //FIXME: Figure out how this should look.
        return _contactController.colleagues(id).then((Iterable<ORModel.Contact> contacts) {
          ulReceptionList.children =

          contacts.map(createColleagueNode).toList();

        });
      });
    }).catchError((error, stack) {
      log.error(
          'Tried to activate contact "${id}" but gave "${error}" \n${stack}');
    });
  }

  void fillSearchComponent() {
    _receptionController.list().then((Iterable<ORModel.Reception> receptions) {
      int compareTo(ORModel.Reception rs1, ORModel.Reception rs2) =>
          rs1.fullName.compareTo(rs2.fullName);

      List list = receptions.toList()..sort(compareTo);

      SC.updateSourceList(list);
    });
  }

  Future receptionContactUpdate(ORModel.Contact ca) {
    return _contactController.updateInReception(ca).then((_) {
      notify.info('Oplysningerne blev gemt.');
    }).catchError((error, stack) {
      notify.error('Ændringerne blev ikke gemt.');
      log.error(
          'Tried to update a Reception Contact, but failed with "${error}", ${stack}');
    });
  }

  Future receptionContactCreate(ORModel.Contact contact) {
    return _contactController
        .addToReception(contact, contact.receptionID)
        .then((_) {
      notify.info('Lageringen gik godt.');
      bus.fire(new ReceptionContactAddedEvent(contact.receptionID, contact.ID));
    }).catchError((error, stack) {
      notify.error(
          'Der skete en fejl, så forbindelsen mellem kontakt og receptionen blev ikke oprettet. ${error}');
      log.error(
          'Tried to update a Reception Contact, but failed with "$error" ${stack}');
    });
  }

  /**
   * Make a [LIElement] that contains field for every information about the Contact in that Reception.
   * If any of the fields changes, save to [saveList] a function that calls [receptionContactHandler] with the changed [ReceptionContact]
   * If you want there to always be this function in [saveList] set alwaysAddToSaveList to true.
   */
  LIElement receptionContactBox(ORModel.Contact contact,
      {bool alwaysAddToSaveList: false}) {
    DivElement div = new DivElement()..classes.add('contact-reception');
    LIElement li = new LIElement()..tabIndex = -1;
    SpanElement header = new SpanElement()
      //TODO: insert name.
      ..text = contact.receptionID.toString()
      ..classes.add('reception-contact-header');
    div.children.add(header);

    ButtonElement delete = new ButtonElement()
      ..text = 'fjern'
      ..onClick.listen((_) => _contactController
          .removeFromReception(contact.ID, contact.receptionID)
          .then((_) => li.parent.children.remove(li)));

    div.children.add(delete);

    //FIXME This code is only nessesary when it's time to migrate from FrontDesk to OpenReception
    NumberInputElement newContactIdInput = new NumberInputElement()
      ..style.marginLeft = '10px'
      ..placeholder = 'Flyt til kontakt med id...';
    ButtonElement moveContact = new ButtonElement()
      ..text = 'Flyt'
      ..onClick.listen((_) {
        try {
          int newContactId = int.parse(newContactIdInput.value);
          _contactController.moveReception(contact.receptionID, contact.ID, newContactId)
              .then((_) {
            notify.info('Oplysningerne er nu flyttet til ${newContactId}');
            activateContact(contact.ID);
          }).catchError((error) {
            notify.info('Oplysningerne blev ikke flyttet. Fejl: ${error}');
          });
        } catch (error) {
          notify.info('Det er kontaktens ID der skal skrive i tal. ${error}');
        }
      });

    div.children.addAll([newContactIdInput, moveContact]);
    //FIXME end of migrate from Frontdesk to OpenReception code

    UListElement department, info, position, relations, responsibility;
    InputElement wantMessage, enabled;
    UListElement backupList,
        emailList,
        handlingList,
        phoneNumbersList,
        workhoursList,
        tagsList;
    EndpointsComponent endpointsContainer;
    DistributionsListComponent distributionsListContainer;
    ContactCalendarComponent calendarComponent;

    Function onChange = () {
      if (!saveList.containsKey(contact.receptionID)) {
        saveList[contact.receptionID] = () {
          ORModel.Contact CA = new ORModel.Contact.empty()
            ..ID = contact.ID
            ..receptionID = contact.receptionID
            ..enabled = enabled.checked
            ..wantsMessage = wantMessage.checked
            ..phones = getPhoneNumbersFromDOM(phoneNumbersList)
            ..backupContacts = getListValues(backupList)
            ..handling = getListValues(handlingList)
            ..workhours = getListValues(workhoursList)
            ..tags = getListValues(tagsList)
            ..departments = getListValues(department)
            ..infos = getListValues(info)
            ..titles = getListValues(position)
            ..relations = getListValues(relations)
            ..responsibilities = getListValues(responsibility);

          return _contactController
              .updateInReception(CA)
              .then((_) => endpointsContainer.save(CA.receptionID, CA.ID))
              .then(
                  (_) => distributionsListContainer.save(CA.receptionID, CA.ID))
              .then((_) => calendarComponent.save(CA.receptionID, CA.ID));
        };
      }
    };

    TableElement table = new TableElement()..classes.add('content-table');
    div.children.add(table);

    TableSectionElement tableBody = new Element.tag('tbody');
    table.children.add(tableBody);

    TableRowElement row;
    TableCellElement leftCell, rightCell;

    row = createTableRowInsertInTable(tableBody);
    leftCell = createTableCellInsertInRow(row);
    rightCell = createTableCellInsertInRow(row);
    wantMessage = createCheckBox(
        leftCell, 'Vil have beskeder', contact.wantsMessage,
        onChange: onChange);
    enabled =
        createCheckBox(rightCell, 'Aktiv', contact.enabled, onChange: onChange);

    row = createTableRowInsertInTable(tableBody);
    leftCell = createTableCellInsertInRow(row);
    rightCell = createTableCellInsertInRow(row);
    department = createListBox(leftCell, 'Afdeling', contact.departments,
        onChange: onChange);
    info = createListBox(rightCell, 'Andet', contact.infos, onChange: onChange);

    row = createTableRowInsertInTable(tableBody);
    leftCell = createTableCellInsertInRow(row);
    rightCell = createTableCellInsertInRow(row);
    position =
        createListBox(leftCell, 'Stilling', contact.titles, onChange: onChange);
    relations = createListBox(rightCell, 'Relationer', contact.relations,
        onChange: onChange);

    row = createTableRowInsertInTable(tableBody);
    leftCell = createTableCellInsertInRow(row)
      ..colSpan = 2; //Because of w3 validation
    responsibility = createListBox(leftCell, 'Ansvar', contact.responsibilities,
        onChange: onChange);

    row = createTableRowInsertInTable(tableBody);
    leftCell = createTableCellInsertInRow(row);
    rightCell = createTableCellInsertInRow(row);
    backupList = createListBox(leftCell, 'Backup', contact.backupContacts,
        onChange: onChange);
    endpointsContainer =
        new EndpointsComponent(rightCell, onChange, _contactController, _endpointController);
    //Saving the future, so we are able to wait on it later.
    endpointsContainer.load(contact.receptionID, contact.ID);

    row = createTableRowInsertInTable(tableBody);
    leftCell = createTableCellInsertInRow(row);
    rightCell = createTableCellInsertInRow(row);
    handlingList = createListBox(leftCell, 'Håndtering', contact.handling,
        onChange: onChange);
    phoneNumbersList =
        createPhoneNumbersList(rightCell, contact.phones, onChange: onChange);

    row = createTableRowInsertInTable(tableBody);
    leftCell = createTableCellInsertInRow(row);
    rightCell = createTableCellInsertInRow(row);
    workhoursList = createListBox(leftCell, 'Arbejdstid', contact.workhours,
        onChange: onChange);
    tagsList =
        createListBox(rightCell, 'Stikord', contact.tags, onChange: onChange);

    row = createTableRowInsertInTable(tableBody);
    leftCell = createTableCellInsertInRow(row);
    rightCell = createTableCellInsertInRow(row);
    distributionsListContainer = new DistributionsListComponent(
        leftCell, onChange, _contactController, _dlistController, _receptionController);
    distributionsListContainer.load(contact);
    calendarComponent =
        new ContactCalendarComponent(rightCell, onChange, _calendarController);
    calendarComponent.load(contact.receptionID, contact.ID);

    li.children.add(div);

    return li;
  }

  TableCellElement createTableCellInsertInRow(TableRowElement row) {
    TableCellElement td = new TableCellElement();
    row.children.add(td);
    return td;
  }

  TableRowElement createTableRowInsertInTable(TableSectionElement table) {
    TableRowElement row = new TableRowElement();
    table.children.add(row);
    return row;
  }

  UListElement createPhoneNumbersList(
      Element container, List<ORModel.PhoneNumber> phonenumbers,
      {Function onChange}) {
    ParagraphElement label = new ParagraphElement();
    UListElement ul = new UListElement()..classes.add('content-list');

    label.text = 'Telefonnumre';

    List<LIElement> children = new List<LIElement>();
    if (phonenumbers != null) {
      for (ORModel.PhoneNumber number in phonenumbers) {
        LIElement li = simpleListElement(number.value, onChange: onChange);
        //TODO: Figure out what value is used for.
        //li.value = number.value != null ? number.value : -1;
        SelectElement kindpicker = new SelectElement()
          ..children.addAll(phonenumberTypes.map(
              (String kind) => new OptionElement(
                  data: kind, value: kind, selected: kind == number.type)))
          ..onChange.listen((_) => onChange());

        SpanElement descriptionContent = new SpanElement()
          ..text = number.description
          ..classes.add('phonenumberdescription');
        InputElement descriptionEditBox = new InputElement(type: 'text');
        editableSpan(descriptionContent, descriptionEditBox, onChange);

        SpanElement billingTypeContent = new SpanElement()
          ..text = number.billing_type
          ..classes.add('phonenumberbillingtype');
        InputElement billingTypeEditBox = new InputElement(type: 'text');
        editableSpan(billingTypeContent, billingTypeEditBox, onChange);

        li.children.addAll([
          kindpicker,
          descriptionContent,
          descriptionEditBox,
          billingTypeContent,
          billingTypeEditBox
        ]);
        children.add(li);
      }
    }

    SortableGroup sortGroup = new SortableGroup()..installAll(children);

    if (onChange != null) {
      sortGroup.onSortUpdate.listen((SortableEvent event) => onChange());
    }

    // Only accept elements from this section.
    sortGroup.accept.add(sortGroup);

    InputElement inputNewItem = new InputElement();
    inputNewItem
      ..classes.add(addNewLiClass)
      ..placeholder = 'Tilføj ny...'
      ..onKeyPress.listen((KeyboardEvent event) {
        KeyEvent key = new KeyEvent.wrap(event);
        if (key.keyCode == Keys.ENTER) {
          String item = inputNewItem.value;
          inputNewItem.value = '';

          LIElement li = simpleListElement(item);
          //A bit of a hack to get a unique id.
          li.value = item.hashCode;
          SelectElement kindpicker = new SelectElement()
            ..children.addAll(phonenumberTypes.map(
                (String kind) => new OptionElement(data: kind, value: kind)))
            ..onChange.listen((_) => onChange());

          SpanElement descriptionContent = new SpanElement()
            ..text = 'kontor'
            ..classes.add('phonenumberdescription');
          InputElement descriptionEditBox = new InputElement(type: 'text')
            ..placeholder = 'beskrivelse';
          editableSpan(descriptionContent, descriptionEditBox, onChange);

          SpanElement billingTypeContent = new SpanElement()
            ..text = 'fastnet'
            ..classes.add('phonenumberbillingtype');
          InputElement billingTypeEditBox = new InputElement(type: 'text')
            ..placeholder = 'taksttype';
          editableSpan(billingTypeContent, billingTypeEditBox, onChange);

          li.children.addAll([
            kindpicker,
            descriptionContent,
            descriptionEditBox,
            billingTypeContent,
            billingTypeEditBox
          ]);

          int index = ul.children.length - 1;
          sortGroup.install(li);
          ul.children.insert(index, li);

          if (onChange != null) {
            onChange();
          }
        } else if (key.keyCode == Keys.ESCAPE) {
          inputNewItem.value = '';
        }
      });

    children.add(new LIElement()..children.add(inputNewItem));

    ul.children
      ..clear()
      ..addAll(children);

    container.children.addAll([label, ul]);

    return ul;
  }

  List<ORModel.PhoneNumber> getPhoneNumbersFromDOM(UListElement element) {
    List<ORModel.PhoneNumber> phonenumbers = new List<ORModel.PhoneNumber>();

    for (LIElement li in element.children) {
      if (!li.classes.contains(addNewLiClass)) {
        SpanElement content = li.children.firstWhere(
            (elem) => elem is SpanElement &&
                elem.classes.contains('contactgenericcontent'),
            orElse: () => null);
        SelectElement kindpicker = li.children.firstWhere(
            (elem) => elem is SelectElement, orElse: () => null);
        SpanElement description = li.children.firstWhere(
            (elem) => elem is SpanElement &&
                elem.classes.contains('phonenumberdescription'),
            orElse: () => null);
        SpanElement billingType = li.children.firstWhere(
            (elem) => elem is SpanElement &&
                elem.classes.contains('phonenumberbillingtype'),
            orElse: () => null);

        if (content != null && kindpicker != null) {
          phonenumbers.add(new ORModel.PhoneNumber.empty()
            ..type = kindpicker.options[kindpicker.selectedIndex].value
            ..value = content.text
            ..description = description.text
            ..billing_type = billingType.text);
        }
      }
    }
    return phonenumbers;
  }

  UListElement createListBox(
      Element container, String labelText, List<String> dataList,
      {Function onChange}) {
    ParagraphElement label = new ParagraphElement();
    UListElement ul = new UListElement()..classes.add('content-list');

    label.text = labelText;
    fillList(ul, dataList, onChange: onChange);

    container.children.addAll([label, ul]);

    return ul;
  }

  TextAreaElement createTextBox(
      Element container, String labelText, String data, {Function onChange}) {
    ParagraphElement label = new ParagraphElement();
    TextAreaElement inputText = new TextAreaElement()..rows = 1;

    label.text = labelText;
    inputText.value = data;

    if (onChange != null) {
      inputText.onChange.listen((_) {
        onChange();
      });
    }

    container.children.addAll([label, inputText]);

    return inputText;
  }

  InputElement createCheckBox(Element container, String labelText, bool data,
      {Function onChange}) {
    ParagraphElement label = new ParagraphElement();
    CheckboxInputElement inputCheckbox = new CheckboxInputElement();

    label.text = labelText;
    inputCheckbox.checked = data;

    if (onChange != null) {
      inputCheckbox.onChange.listen((_) {
        onChange();
      });
    }

    container.children.addAll([label, inputCheckbox]);
    return inputCheckbox;
  }

  void saveChanges() {
    int contactId = selectedContactId;
    if (contactId != null && contactId > 0 && createNew == false) {
      List<Future> work = new List<Future>();
      ORModel.BaseContact updatedContact = new ORModel.BaseContact.empty()
        ..id = contactId
        ..fullName = inputName.value
        ..contactType = inputType.selectedOptions.first != null
            ? inputType.selectedOptions.first.value
            : inputType.options.first.value
        ..enabled = inputEnabled.checked;

      work.add(_contactController.update(updatedContact).then((_) {
        //TODO: Show a message that tells the user, that the changes went through.
        refreshList();
      }).catchError((error) {
        log.error(
            'Tried to update a contact but failed with error "${error}" from body: "${JSON.encode(updatedContact)}"');
      }));

      work.addAll(saveList.values.map((f) => f()));

      //When all updates are applied. Reload the contact.
      Future.wait(work).then((_) {
        return activateContact(contactId);
      }).catchError((error, stack) {
        log.error(
            'Contact was appling update for ${contactId} when "$error", ${stack}');
      });
    } else if (createNew) {
      ORModel.BaseContact newContact = new ORModel.BaseContact.empty()
        ..fullName = inputName.value
        ..contactType = inputType.selectedOptions.first != null
            ? inputType.selectedOptions.first.value
            : inputType.options.first.value
        ..enabled = inputEnabled.checked;

      _contactController
          .create(newContact)
          .then((ORModel.BaseContact responseContact) {
        bus.fire(new ContactAddedEvent(responseContact.id));
        refreshList();
        activateContact(responseContact.id);
        notify.info('Kontaktpersonen blev oprettet.');
      }).catchError((error) {
        notify.info(
            'Der skete en fejl i forbindelse med oprettelsen af kontaktpersonen. ${error}');
        log.error(
            'Tried to make a new contact but failed with error "${error}" from body: "${JSON.encode(newContact)}"');
      });
    }
  }

  void clearContent() {
    inputName.value = '';
    inputType.selectedIndex = 0;
    inputEnabled.checked = true;
    ulReceptionContacts.children.clear();
  }

  void createContact() {
    selectedContactId = 0;
    buttonSave.text = 'Opret';
    buttonSave.disabled = false;
    buttonDelete.disabled = true;
    buttonJoinReception.disabled = true;
    ulReceptionList.children.clear();
    clearContent();
    createNew = true;
  }

  void addReceptionToContact() {
    if (SC.currentElement != null && selectedContactId > 0) {
      ORModel.Reception reception = SC.currentElement;

      ORModel.Contact template = new ORModel.Contact.empty()
        ..receptionID = reception.ID
        ..ID = selectedContactId;

      _contactController
          .addToReception(template, reception.ID)
          .then((ORModel.Contact createdContact) {
        ulReceptionContacts.children..add(receptionContactBox(createdContact));
      });
    }
  }

  LIElement createReceptionNode(ORModel.Reception reception) {
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
        bus.fire(new WindowChanged(Menu.RECEPTION_WINDOW, data));
      });

    UListElement contactsUl = new UListElement()
      ..classes.add('zebra-odd');

    _contactController.list(reception.ID)
      .then((Iterable<ORModel.Contact> contacts) {
        contactsUl.children = contacts
              .map((ORModel.Contact collegue) =>
                  createColleagueNode(collegue))
              .toList();

    });


    rootNode.children.addAll([receptionNode, contactsUl]);
    return rootNode;
  }

  /**
   * TODO: Add reception Name.
   */
  LIElement createColleagueNode(ORModel.Contact collegue) {
    return new LIElement()
      ..classes.add('clickable')
      ..classes.add('colleague')
      ..text = '${collegue.fullName} (${collegue.receptionID})'
      ..onClick.listen((_) {
        Map data = {'contact_id': collegue.ID, 'reception_id': collegue.receptionID};
        bus.fire(new WindowChanged(Menu.CONTACT_WINDOW, data));
      });
  }

  LIElement createOrganizationNode(ORModel.Organization organization) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${organization.fullName}'
      ..onClick.listen((_) {
        Map data = {'organization_id': organization.id,};
        bus.fire(new WindowChanged(Menu.ORGANIZATION_WINDOW, data));
      });
    return li;
  }

  void deleteSelectedContact() {
    if (!createNew && selectedContactId > 0) {
      _contactController.remove(selectedContactId).then((_) {
        bus.fire(new ContactRemovedEvent(selectedContactId));
        refreshList();
        clearContent();
        buttonSave.disabled = true;
        buttonDelete.disabled = true;
        buttonJoinReception.disabled = true;
        selectedContactId = 0;
      }).catchError((error) {
        log.error(
            'Failed to delete contact "${selectedContactId}" got "$error"');
      });
    } else {
      log.error(
          'Failed to delete. createNew: ${createNew} id: ${selectedContactId}');
    }
  }
}
