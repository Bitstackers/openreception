library contact.view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:html5_dnd/html5_dnd.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../lib/eventbus.dart';
import '../lib/logger.dart' as log;
import '../lib/model.dart';
import '../notification.dart' as notify;
import '../lib/request.dart' as request;
import '../lib/searchcomponent.dart';
import '../lib/utilities.dart';
import '../lib/view_utilities.dart';

part 'components/contact_calendar.dart';
part 'components/distributionlist.dart';
part 'components/endpoint.dart';

typedef Future HandleReceptionContact(ReceptionContact receptionContact);
typedef Future LazyFuture();

class ContactView {
  String viewName = 'contact';
  DivElement element;
  UListElement ulContactList;
  UListElement ulReceptionContacts;
  UListElement ulReceptionList;
  UListElement ulOrganizationList;
  List<Contact> contactList = new List<Contact>();
  SearchInputElement searchBox;

  TextAreaElement inputName;
  SelectElement inputType;
  SpanElement spanContactId;
  CheckboxInputElement inputEnabled;

  ButtonElement buttonSave, buttonCreate, buttonDelete, buttonJoinReception;
  DivElement receptionOuterSelector;

  SearchComponent<Reception> SC;
  int selectedContactId;
  bool createNew = false;

  Map<int, LazyFuture> saveList = new Map<int, LazyFuture>();
  List<String> phonenumberTypes = ['PSTN', 'SIP'];

  ContactView(DivElement this.element) {
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
    receptionOuterSelector = element.querySelector('#contact-reception-selector');

    SC = new SearchComponent<Reception>(receptionOuterSelector, 'contact-reception-searchbox')
        ..listElementToString = receptionToSearchboxString
        ..searchFilter = receptionSearchHandler
        ..searchPlaceholder = 'Søg...';

    fillSearchComponent();

    registrateEventHandlers();

    refreshList();

    request.getContacttypeList().then((List<String> typesList) {
      inputType.children.addAll(typesList.map((type) => new OptionElement(data:
          type, value: type)));
    });

    EndpointsComponent.loadAddressTypes();
  }

  String receptionToSearchboxString(Reception reception, String searchterm) {
    return '${reception.full_name}';
  }

  bool receptionSearchHandler(Reception reception, String searchTerm) {
    return reception.full_name.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
      if (event.containsKey('contact_id')) {
        activateContact(event['contact_id'], event['reception_id']);
      }
    });

    bus.on(Invalidate.receptionAdded).listen((_) {
      fillSearchComponent();
    });

    bus.on(Invalidate.receptionRemoved).listen((_) {
      fillSearchComponent();
    });

    buttonSave.onClick.listen((_) => saveChanges());
    buttonCreate.onClick.listen((_) => createContact());
    buttonJoinReception.onClick.listen((_) => addReceptionToContact());
    buttonDelete.onClick.listen((_) => deleteSelectedContact());
    searchBox.onInput.listen((_) => performSearch());
  }

  void refreshList() {
    request.getEveryContact().then((List<Contact> contacts) {
      contacts.sort((a, b) => a.full_name.compareTo(b.full_name));
      this.contactList = contacts;
      performSearch();
    }).catchError((error) {
      log.error('Tried to fetch organization but got error: $error');
    });
  }

  void performSearch() {
    String searchTerm = searchBox.value;
    ulContactList.children
        ..clear()
        ..addAll(contactList.where((e) => e.full_name.toLowerCase().contains(
            searchTerm.toLowerCase())).map(makeContactNode));
  }

  LIElement makeContactNode(Contact contact) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${contact.full_name}'
      ..dataset['contactid'] = '${contact.id}'
      ..onClick.listen((_) => activateContact(contact.id));
    return li;
  }

  void highlightContactInList(int id) {
    ulContactList.children.forEach((LIElement li) => li.classes.toggle('highlightListItem', li.dataset['contactid'] == '$id'));
  }

  void activateContact(int id, [int reception_id]) {
    request.getContact(id).then((Contact contact) {
      buttonSave.text = 'Gem';
      buttonSave.disabled = false;
      buttonDelete.disabled = false;
      buttonJoinReception.disabled = false;
      createNew = false;

      inputName.value = contact.full_name;
      inputType.options.forEach((option) => option.selected = option.value ==
          contact.type);
      inputEnabled.checked = contact.enabled;
      spanContactId.text = '${contact.id}';
      selectedContactId = contact.id;

      highlightContactInList(id);

      return request.getAContactsEveryReception(id).then(
          (List<ReceptionContact_ReducedReception> contacts) {
        if (contacts != null) {
          saveList.clear();
          contacts.sort(ReceptionContact_ReducedReception.sortByReceptionName);
          ulReceptionContacts.children
              ..clear()
              ..addAll(contacts.map((ReceptionContact_ReducedReception receptioncontact) =>
                  receptionContactBox(receptioncontact, receptionContactUpdate, selected: receptioncontact.receptionId == reception_id)));

        //Rightbar
        request.getContactsOrganizationList(id).then((List<Organization> organizations) {
          organizations.sort(Organization.sortByName);
          ulOrganizationList.children
              ..clear()
              ..addAll(organizations.map(makeOrganizationNode));
        }).catchError((error, stack) {
          log.error('Tried to update contact "${id}"s rightbar but got "${error}" \n${stack}');
        });

        return request.getContactsColleagues(id).then((List<ReceptionColleague> Receptions) {
          ulReceptionList.children.clear();

          if(Receptions.isNotEmpty) {
            Receptions.sort(ReceptionColleague.sortByName);
            ulReceptionList.children
                ..addAll(Receptions.map(makeReceptionNode).reduce(union));
          }
          });
        }
      });
    }).catchError((error, stack) {
      log.error('Tried to activate contact "${id}" but gave "${error}" \n${stack}');
    });
  }

  void fillSearchComponent() {
    request.getReceptionList().then((List<Reception> receptions) {
      SC.updateSourceList(receptions);
    });
  }

  Future receptionContactUpdate(ReceptionContact RC) {
    return request.updateReceptionContact(RC.receptionId, RC.contactId, JSON.encode(RC)).then((_) {
      notify.info('Oplysningerne blev gemt.');
    }).catchError((error, stack) {
      notify.error('Ændringerne blev ikke gemt.');
      log.error('Tried to update a Reception Contact, but failed with "${error}", ${stack}');
    });
  }

  Future receptionContactCreate(ReceptionContact RC) {
    return request.createReceptionContact(RC.receptionId, RC.contactId,
        JSON.encode(RC)).then((_) {
      Map event = {
        "receptionId": RC.receptionId,
        "contactId": RC.contactId
      };
      notify.info('Lageringen gik godt.');
      bus.fire(Invalidate.receptionContactAdded, event);
    }).catchError((error, stack) {
      notify.error('Der skete en fejl, så forbindelsen mellem kontakt og receptionen blev ikke oprettet. ${error}');
      log.error('Tried to update a Reception Contact, but failed with "$error" ${stack}');
    });
  }

  /**
   * Make a [LIElement] that contains field for every information about the Contact in that Reception.
   * If any of the fields changes, save to [saveList] a function that calls [receptionContactHandler] with the changed [ReceptionContact]
   * If you want there to always be this function in [saveList] set alwaysAddToSaveList to true.
   */
  LIElement receptionContactBox(ReceptionContact_ReducedReception contact, HandleReceptionContact receptionContactHandler,
                                {bool selected: false, bool alwaysAddToSaveList: false}) {
    DivElement div = new DivElement()..classes.add('contact-reception');
    LIElement li = new LIElement()
        ..tabIndex = -1;
    SpanElement header = new SpanElement()
        ..text = contact.receptionName
        ..classes.add('reception-contact-header');
    div.children.add(header);

    ButtonElement delete = new ButtonElement()
        ..text = 'fjern'
        ..onClick.listen((_) {
          saveList[contact.receptionId] = () {
            return request.deleteReceptionContact(contact.receptionId,
                contact.contactId).then((_) {
              Map event = {
                "receptionId": contact.receptionId,
                "contactId": contact.contactId
              };
              bus.fire(Invalidate.receptionContactRemoved, event);
            }).catchError((error) {
              log.error('deleteReceptionContact error: "error"');
            });
          };
          li.parent.children.remove(li);
        });

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
        request.moveReceptionContact(contact.receptionId, contact.contactId, newContactId).then((_) {
          notify.info('Oplysningerne er nu flyttet til ${newContactId}');
          activateContact(contact.contactId);
        }).catchError((error) {
          notify.info('Oplysningerne blev ikke flyttet. Fejl: ${error}');
        });
      } catch(error) {
        notify.info('Det er kontaktens ID der skal skrive i tal. ${error}');
      }
    });

    div.children.addAll([newContactIdInput, moveContact]);
    //FIXME end of migrate from Frontdesk to OpenReception code

    TextAreaElement department, info, position, relations, responsibility;
    InputElement wantMessage, enabled;
    UListElement backupList, emailList, handlingList, phoneNumbersList,
        workhoursList, tagsList;
    EndpointsComponent endpointsContainer;
    DistributionsListComponent distributionsListContainer;
    ContactCalendarComponent calendarComponent;

    Function onChange = () {
      if (!saveList.containsKey(contact.receptionId)) {
        saveList[contact.receptionId] = () {
          ReceptionContact RC = new ReceptionContact()
              ..attributes = contact.attributes //There can be more values than we know of.
              ..contactId = contact.contactId
              ..receptionId = contact.receptionId
              ..contactEnabled = enabled.checked
              ..wantsMessages = wantMessage.checked
              ..phoneNumbers = getPhoneNumbersFromDOM(phoneNumbersList)

              ..backup = getListValues(backupList)
              //..emailaddresses = getListValues(emailList)
              ..handling = getListValues(handlingList)
              //..telephonenumbers = getListValues(telephoneNumbersList)
              ..workhours = getListValues(workhoursList)
              ..tags = getListValues(tagsList)

              ..department = department.value
              ..info = info.value
              ..position = position.value
              ..relations = relations.value
              ..responsibility = responsibility.value;

          return receptionContactHandler(RC)
              .then((_) => endpointsContainer.save(RC.receptionId, RC.contactId))
              .then((_) => distributionsListContainer.save(RC.receptionId, RC.contactId))
              .then((_) => calendarComponent.save(RC.receptionId, RC.contactId));
        };
      }
    };

    List<Future> loadingJobs = new List<Future>();
    TableElement table = new TableElement()..classes.add('content-table');
    div.children.add(table);

    TableSectionElement tableBody = new Element.tag('tbody');
    table.children.add(tableBody);

    TableRowElement row;
    TableCellElement leftCell, rightCell;


    row = makeTableRowInsertInTable(tableBody);
    leftCell = makeTableCellInsertInRow(row);
    rightCell = makeTableCellInsertInRow(row);
    wantMessage = makeCheckBox(leftCell, 'Vil have beskeder', contact.wantsMessages, onChange: onChange);
    enabled = makeCheckBox(rightCell, 'Aktiv', contact.contactEnabled, onChange: onChange);

    row = makeTableRowInsertInTable(tableBody);
    leftCell = makeTableCellInsertInRow(row);
    rightCell = makeTableCellInsertInRow(row);
    department = makeTextBox(leftCell, 'Afdelling', contact.department, onChange: onChange);
    info = makeTextBox(rightCell, 'Andet', contact.info, onChange: onChange);


    row = makeTableRowInsertInTable(tableBody);
    leftCell = makeTableCellInsertInRow(row);
    rightCell = makeTableCellInsertInRow(row);
    position = makeTextBox(leftCell, 'Stilling', contact.position, onChange: onChange);
    relations = makeTextBox(rightCell, 'Relationer', contact.relations, onChange: onChange);

    row = makeTableRowInsertInTable(tableBody);
    leftCell = makeTableCellInsertInRow(row);
    responsibility = makeTextBox(leftCell, 'Ansvar', contact.responsibility, onChange: onChange);

    row = makeTableRowInsertInTable(tableBody);
    leftCell = makeTableCellInsertInRow(row);
    rightCell = makeTableCellInsertInRow(row);
    backupList = makeListBox(leftCell, 'Backup', contact.backup, onChange: onChange);
    //emailList = makeListBox(rightCell, 'E-mail', contact.emailaddresses, onChange: onChange);
    endpointsContainer = new EndpointsComponent(rightCell, onChange);
    //Saving the future, so we are able to wait on it later.
    loadingJobs.add(endpointsContainer.load(contact.receptionId, contact.contactId));

    row = makeTableRowInsertInTable(tableBody);
    leftCell = makeTableCellInsertInRow(row);
    rightCell = makeTableCellInsertInRow(row);
    handlingList = makeListBox(leftCell, 'Håndtering', contact.handling, onChange: onChange);
    phoneNumbersList = makePhoneNumbersList(rightCell, contact.phoneNumbers, onChange: onChange);

    row = makeTableRowInsertInTable(tableBody);
    leftCell = makeTableCellInsertInRow(row);
    rightCell = makeTableCellInsertInRow(row);
    workhoursList = makeListBox(leftCell, 'Arbejdstid', contact.workhours, onChange: onChange);
    tagsList = makeListBox(rightCell, 'Stikord', contact.tags, onChange: onChange);

    row = makeTableRowInsertInTable(tableBody);
    leftCell = makeTableCellInsertInRow(row);
    rightCell = makeTableCellInsertInRow(row);
    distributionsListContainer = new DistributionsListComponent(leftCell, onChange);
    loadingJobs.add(distributionsListContainer.load(contact.receptionId, contact.contactId));
    calendarComponent = new ContactCalendarComponent(rightCell, onChange);
    loadingJobs.add(calendarComponent.load(contact.receptionId, contact.contactId));


    //In case of creating. You always want it in saveList.
    if (alwaysAddToSaveList) {
      onChange();
    }

    if(selected) {
      Future.wait(loadingJobs).then((_) {
        li.focus();
      });
    }

    li.children.add(div);
    return li;
  }

  TableCellElement makeTableCellInsertInRow(TableRowElement row) {
    TableCellElement td = new TableCellElement();
    row.children.add(td);
    return td;
  }

  TableRowElement makeTableRowInsertInTable(Element table) {
    TableRowElement row = new TableRowElement();
    table.children.add(row);
    return row;
  }

  UListElement makePhoneNumbersList(Element container, List<Phone> phonenumbers, {Function onChange}) {
    LabelElement label = new LabelElement();
    UListElement ul = new UListElement()..classes.add('content-list');

    label.text = 'Telefonnumre';

    List<LIElement> children = new List<LIElement>();
      if (phonenumbers != null) {
        for (Phone number in phonenumbers) {
          LIElement li = simpleListElement(number.value, onChange: onChange);
          li.value = number.id != null ? number.id : -1;
          SelectElement kindpicker = new SelectElement()
            ..children.addAll(phonenumberTypes.map((String kind) => new OptionElement(data: kind, value: kind, selected: kind == number.kind)))
            ..onChange.listen((_) => onChange());

          SpanElement descriptionContent = new SpanElement()
            ..text = number.description
            ..classes.add('phonenumberdescription');
          InputElement descriptionEditBox = new InputElement(type: 'text');
          editableSpan(descriptionContent, descriptionEditBox, onChange);

          SpanElement billTypeContent = new SpanElement()
            ..text = number.bill_type
            ..classes.add('phonenumberbilltype');
          InputElement billTypeEditBox = new InputElement(type: 'text');
          editableSpan(billTypeContent, billTypeEditBox, onChange);

          li.children.addAll([kindpicker, descriptionContent, descriptionEditBox, billTypeContent, billTypeEditBox]);
          children.add(li);
        }
      }

      SortableGroup sortGroup = new SortableGroup()
        ..installAll(children);

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
              ..children.addAll(phonenumberTypes.map((String kind) => new OptionElement(data: kind, value: kind)))
              ..onChange.listen((_) => onChange());

            SpanElement descriptionContent = new SpanElement()
              ..text = 'kontor'
              ..classes.add('phonenumberdescription');
            InputElement descriptionEditBox = new InputElement(type: 'text')
              ..placeholder = 'beskrivelse';
            editableSpan(descriptionContent, descriptionEditBox, onChange);

            SpanElement billTypeContent = new SpanElement()
              ..text = 'fastnet'
              ..classes.add('phonenumberbilltype');
            InputElement billTypeEditBox = new InputElement(type: 'text')
              ..placeholder = 'taksttype';
            editableSpan(billTypeContent, billTypeEditBox, onChange);

            li.children.addAll([kindpicker, descriptionContent, descriptionEditBox, billTypeContent, billTypeEditBox]);

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

  List<Phone> getPhoneNumbersFromDOM(UListElement element) {
    List<Phone> phonenumbers = new List<Phone>();

    for (LIElement li in element.children) {
      if (!li.classes.contains(addNewLiClass)) {
        SpanElement content = li.children.firstWhere((elem) => elem is SpanElement && elem.classes.contains('contactgenericcontent'), orElse: () => null);
        SelectElement kindpicker = li.children.firstWhere((elem) => elem is SelectElement, orElse: () => null);
        SpanElement description = li.children.firstWhere((elem) => elem is SpanElement && elem.classes.contains('phonenumberdescription'), orElse: () => null);
        SpanElement billType = li.children.firstWhere((elem) => elem is SpanElement && elem.classes.contains('phonenumberbilltype'), orElse: () => null);

        if (content != null && kindpicker != null) {
          phonenumbers.add(new Phone()
            ..id = li.value
            ..kind = kindpicker.options[kindpicker.selectedIndex].value
            ..value = content.text
            ..description = description.text
            ..bill_type = billType.text);
        }
      }
    }
    return phonenumbers;
  }

  UListElement makeListBox(Element container, String labelText, List<String> dataList, {Function onChange}) {
    LabelElement label = new LabelElement();
    UListElement ul = new UListElement()..classes.add('content-list');

    label.text = labelText;
    fillList(ul, dataList, onChange: onChange);

    container.children.addAll([label, ul]);

    return ul;
  }

  TextAreaElement makeTextBox(Element container, String labelText, String data, {Function onChange}) {
    LabelElement label = new LabelElement();
    TextAreaElement inputText = new TextAreaElement()
      ..rows = 1;

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

  InputElement makeCheckBox(Element container, String labelText, bool
      data, {Function onChange}) {
    LabelElement label = new LabelElement();
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
      Contact updatedContact = new Contact()
          ..id = contactId
          ..full_name = inputName.value
          ..type = inputType.selectedOptions.first != null ?
              inputType.selectedOptions.first.value : inputType.options.first.value
          ..enabled = inputEnabled.checked;

      work.add(request.updateContact(contactId, JSON.encode(updatedContact)).then(
          (_) {
        //Show a message that tells the user, that the changes went through.
        refreshList();
      }).catchError((error) {
        log.error('Tried to update a contact but failed with error "${error}" from body: "${JSON.encode(updatedContact)}"');
      }));

      work.addAll(saveList.values.map((f) => f()));

      //When all updates are applied. Reload the contact.
      Future.wait(work).then((_) {
        return activateContact(contactId);
      }).catchError((error, stack) {
        log.error('Contact was appling update for ${contactId} when "$error", ${stack}');
      });

    } else if (createNew) {
      Contact newContact = new Contact()
          ..full_name = inputName.value
          ..type = inputType.selectedOptions.first != null ?
              inputType.selectedOptions.first.value : inputType.options.first.value
          ..enabled = inputEnabled.checked;

      request.createContact(JSON.encode(newContact)).then((Map response) {
        bus.fire(Invalidate.contactAdded, null);
        refreshList();
        activateContact(response['id']);
        notify.info('Kontaktpersonen blev oprettet.');
      }).catchError((error) {
        notify.info('Der skete en fejl i forbindelse med oprettelsen af kontaktpersonen. ${error}');
        log.error('Tried to make a new contact but failed with error "${error}" from body: "${JSON.encode(newContact)}"');
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
      Reception reception = SC.currentElement;

      ReceptionContact_ReducedReception template =
          new ReceptionContact_ReducedReception()
          ..organizationId = reception.organization_id

          ..receptionId = reception.id
          ..receptionName = reception.full_name
          ..receptionEnabled = reception.enabled
          ..contactId = selectedContactId
          ..wantsMessages = true
          ..contactEnabled = true

          ..department = ''
          ..info = ''
          ..position = ''
          ..relations = ''
          ..responsibility = ''

          ..backup = []
          ..emailaddresses = []
          ..handling = []
          //..telephonenumbers = []
          ..workhours = []
          ..tags = [];

      ulReceptionContacts.children..add(receptionContactBox(template,
          receptionContactCreate, alwaysAddToSaveList: true));
    }
  }

  List<LIElement> makeReceptionNode(ReceptionColleague reception) {
    // First node is the receptionname. Clickable to the reception
    //   Second node is a list of contacts in that reception. Could make it lazy loading with a little plus, that "expands" (Fetches the data) the list

    LIElement receptionLi = new LIElement()
        ..classes.add('clickable')
        ..classes.add('receptioncolleague')
        ..text = reception.full_name
        ..onClick.listen((_) {
          Map event = {
            'window': 'reception',
            'organization_id': reception.organization_id,
            'reception_id': reception.id
          };
          bus.fire(windowChanged, event);
        });
    return [receptionLi]..addAll(reception.contacts.map((Colleague collegue) => makeColleagueNode(collegue, reception.id)));
  }

  LIElement makeColleagueNode(Colleague collegue, int receptionId) {
    return new LIElement()
      ..classes.add('clickable')
      ..classes.add('colleague')
      ..text = collegue.full_name
      ..onClick.listen((_) {
        Map event = {
          'window': 'contact',
          'contact_id': collegue.id,
          'reception_id': receptionId
        };
        bus.fire(windowChanged, event);
      });
  }

  LIElement makeOrganizationNode(Organization organization) {
    LIElement li = new LIElement()
        ..classes.add('clickable')
        ..text = '${organization.full_name}'
        ..onClick.listen((_) {
          Map event = {
            'window': 'organization',
            'organization_id': organization.id,
          };
          bus.fire(windowChanged, event);
        });
    return li;
  }

  void deleteSelectedContact() {
    if (!createNew && selectedContactId > 0) {
      request.deleteContact(selectedContactId).then((_) {
        bus.fire(Invalidate.contactRemoved, selectedContactId);
        refreshList();
        clearContent();
        buttonSave.disabled = true;
        buttonDelete.disabled = true;
        buttonJoinReception.disabled = true;
        selectedContactId = 0;
      }).catchError((error) {
        log.error('Failed to delete contact "${selectedContactId}" got "$error"');
      });
    } else {
      log.error('Failed to delete. createNew: ${createNew} id: ${selectedContactId}');
    }
  }
}


