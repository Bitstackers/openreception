library contact.view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:html5_dnd/html5_dnd.dart';

import '../lib/eventbus.dart';
import '../lib/logger.dart' as log;
import '../lib/model.dart';
import '../notification.dart' as notify;
import '../lib/request.dart' as request;
import '../lib/searchcomponent.dart';
import '../lib/utilities.dart';
import '../lib/view_utilities.dart';

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

    SC = new SearchComponent<Reception>(receptionOuterSelector,
        'contact-reception-searchbox')
        ..listElementToString = receptionToSearchboxString
        ..searchFilter = receptionSearchHandler;

    fillSearchComponent();

    registrateEventHandlers();

    refreshList();

    request.getContacttypeList().then((List<String> typesList) {
      inputType.children.addAll(typesList.map((type) => new OptionElement(data:
          type, value: type)));
    });

    request.getAddressTypeList().then((List<String> types) {
      EndpointsComponent.addressTypes = types;
    });
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
    return request.updateReceptionContact(RC.receptionId, RC.contactId, RC.toJson()).catchError((error) {
      log.error('Tried to update a Reception Contact, but failed with "$error"');
    });
  }

  Future receptionContactCreate(ReceptionContact RC) {
    return request.createReceptionContact(RC.receptionId, RC.contactId,
        RC.toJson()).then((_) {
      Map event = {
        "receptionId": RC.receptionId,
        "contactId": RC.contactId
      };
      bus.fire(Invalidate.receptionContactAdded, event);
    }).catchError((error) {
      log.error('Tried to update a Reception Contact, but failed with "$error"');
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
    //

    TextAreaElement department, info, position, relations, responsibility;
    InputElement wantMessage, enabled;
    UListElement backupList, emailList, handlingList, phoneNumbersList,
        workhoursList, tagsList;
    EndpointsComponent endpointsContainer;
    DistributionsListComponent distributionsListContainer;

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
              .then((_) => distributionsListContainer.save(RC.receptionId, RC.contactId));
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
    wantMessage = makeCheckBox(leftCell, 'Vil have beskeder',
        contact.wantsMessages, onChange: onChange);
    enabled = makeCheckBox(rightCell, 'Aktiv', contact.wantsMessages, onChange:
        onChange);

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
    handlingList = makeListBox(leftCell, 'Håndtering', contact.handling,
        onChange: onChange);
    phoneNumbersList = makePhoneNumbersList(rightCell, contact.phoneNumbers, onChange: onChange);

    row = makeTableRowInsertInTable(tableBody);
    leftCell = makeTableCellInsertInRow(row);
    rightCell = makeTableCellInsertInRow(row);
    workhoursList = makeListBox(leftCell, 'Arbejdstid', contact.workhours,
        onChange: onChange);
    tagsList = makeListBox(rightCell, 'Stikord', contact.tags, onChange:
        onChange);

    row = makeTableRowInsertInTable(tableBody);
    leftCell = makeTableCellInsertInRow(row);
    distributionsListContainer = new DistributionsListComponent(leftCell, onChange);
    loadingJobs.add(distributionsListContainer.load(contact.receptionId, contact.contactId));

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

      work.add(request.updateContact(contactId, updatedContact.toJson()).then(
          (_) {
        //Show a message that tells the user, that the changes went through.
        refreshList();
      }).catchError((error) {
        log.error(
            'Tried to update a contact but failed with error "${error}" from body: "${updatedContact.toJson()}"'
            );
      }));

      work.addAll(saveList.values.map((f) => f()));

      //When all updates are applied. Reload the contact.
      Future.wait(work).then((_) {
        //TODO Remove.
        log.info('Activating Contact.');

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

      request.createContact(newContact.toJson()).then((Map response) {
        //TODO Success Show message?
        bus.fire(Invalidate.contactAdded, null);
        refreshList();
        activateContact(response['id']);
      }).catchError((error) {
        log.error('Tried to make a new contact but failed with error "${error}" from body: "${newContact.toJson()}"');
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

      //TODO Warning, This could go wrong if not fixed with the new design of the collegues list.
      ulReceptionContacts.children..add(receptionContactBox(template,
          receptionContactCreate, alwaysAddToSaveList: true));
    }
  }

  List<LIElement> makeReceptionNode(ReceptionColleague reception) {
    //TODO First node is the receptionname. Clickable to the reception
    //     Second is a list of contacts in that reception. Could make it lazy loading with a little plus, that "expands" (Fetches the data) the list

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

class EndpointsComponent {
  static List<String> addressTypes = [];

  Element _element;
  Function _onChange;
  List<Endpoint> persistenceEndpoint = [];
  UListElement _ul = new UListElement();
  LabelElement header = new LabelElement()
    ..text = 'Kontaktpunkter';

  EndpointsComponent(Element this._element, Function this._onChange) {
    _element.children.add(header);
    _element.children.add(_ul);
  }

  void clear() {
    _ul.children.clear();
    persistenceEndpoint = [];
  }

  Future load(int receptionId, int contactId) {
    persistenceEndpoint = [];
    return request.getEndpointsList(receptionId, contactId).then((List<Endpoint> list) {
      populateUL(list);
    });
  }

  void populateUL(List<Endpoint> list) {
    persistenceEndpoint = list;
    _ul.children
      ..clear()
      ..addAll(list.map(_makeEndpointRow))
      ..add(_makeNewEndpointRow());
  }

  LIElement _makeNewEndpointRow() {
    LIElement li = new LIElement();

    ButtonElement createButton = new ButtonElement()
      ..text = 'Ny'
      ..onClick.listen((_) {
        Endpoint endpoint = new Endpoint()
          ..address = 'mig@eksempel.dk'
          ..enabled = true;
        LIElement row = _makeEndpointRow(endpoint);
        int index = _ul.children.length - 1;
        _ul.children.insert(index, row);
        if(_onChange != null) {
          _onChange();
        }
    });

    li.children.addAll([createButton]);
    return li;
  }

  LIElement _makeEndpointRow(Endpoint endpoint) {
    LIElement li = new LIElement();

    SpanElement address = new SpanElement()
      ..classes.add('contact-endpoint-address')
      ..text = endpoint.address;
    InputElement addressEditBox = new InputElement(type: 'text');
    editableSpan(address, addressEditBox, _onChange);

    SelectElement typePicker = new SelectElement()
      ..classes.add('contact-endpoint-addresstype')
      ..children.addAll(addressTypes.map((String type) => new OptionElement(data: type, value: type, selected: type == endpoint.addressType)))
      ..onChange.listen((_) {
      if(_onChange != null) {
        _onChange();
      }
    });

    LabelElement confidentialLabel = new LabelElement()
      ..text = 'Fortrolig';
    CheckboxInputElement confidentialCheckbox = new CheckboxInputElement()
      ..classes.add('contact-endpoint-confidential')
      ..checked = endpoint.confidential
      ..onChange.listen((_) {
      if(_onChange != null) {
        _onChange();
      }
    });

    LabelElement enabledLabel = new LabelElement()
      ..text = 'Aktiv';
    CheckboxInputElement enabledCheckbox = new CheckboxInputElement()
      ..classes.add('contact-endpoint-enabled')
      ..checked = endpoint.enabled
      ..onChange.listen((_) {
        if(_onChange != null) {
          _onChange();
        }
      });

    LabelElement priorityLabel = new LabelElement()
      ..text = 'prioritet';
    NumberInputElement PriorityCheckbox = new NumberInputElement()
      ..classes.add('contact-endpoint-priority')
      ..value = (endpoint.priority == null ? 0 : endpoint.priority).toString()
      ..onInput.listen((_) {
        if(_onChange != null) {
          _onChange();
        }
    });

    LabelElement descriptionLabel = new LabelElement()
      ..text = 'note:';
    TextInputElement descriptionInput = new TextInputElement()
      ..classes.add('contact-endpoint-description')
      ..value = endpoint.description
      ..onInput.listen((_) {
        if(_onChange != null) {
          _onChange();
        }
    });

    //TODO Make it do something.
    ButtonElement deleteButton = new ButtonElement()
      ..text = 'slet'
      ..onClick.listen((_) {
      _ul.children.remove(li);
      if(_onChange != null) {
        _onChange();
      }
    });

    return li
        ..children.addAll([address, addressEditBox, typePicker,
                           confidentialLabel, confidentialCheckbox,
                           enabledLabel, enabledCheckbox,
                           priorityLabel, PriorityCheckbox,
                           descriptionLabel, descriptionInput,
                           deleteButton]);
  }

  Future save(int receptionId, int contactId) {
    List<Endpoint> foundEndpoints = [];

    for(LIElement item in _ul.children) {
      SpanElement addressSpan = item.querySelector('.contact-endpoint-address');
      SelectElement addressTypePicker = item.querySelector('.contact-endpoint-addresstype');
      CheckboxInputElement confidentialBox = item.querySelector('.contact-endpoint-confidential');
      CheckboxInputElement enabledBox = item.querySelector('.contact-endpoint-enabled');
      NumberInputElement priorityBox = item.querySelector('.contact-endpoint-priority');
      TextInputElement descriptionBox = item.querySelector('.contact-endpoint-description');

      if(addressSpan != null && addressTypePicker != null && confidentialBox != null && enabledBox != null && priorityBox != null) {
        Endpoint endpoint = new Endpoint()
          ..receptionId = receptionId
          ..contactId = contactId
          ..address = addressSpan.text
          ..addressType = addressTypePicker.selectedOptions.first.value
          ..confidential = confidentialBox.checked
          ..enabled = enabledBox.checked
          ..priority = int.parse(priorityBox.value)
          ..description = descriptionBox.value;
        foundEndpoints.add(endpoint);
      }
    }

    List<Future> worklist = new List<Future>();

    //Inserts
    for(Endpoint endpoint in foundEndpoints) {
      if(!persistenceEndpoint.any((Endpoint e) => e.address == endpoint.address && e.addressType == endpoint.addressType)) {
        //Insert Endpoint
        worklist.add(request.createEndpoint(receptionId, contactId, endpoint.toJson()));
      }
    }

    //Deletes
    for(Endpoint endpoint in persistenceEndpoint) {
      if(!foundEndpoints.any((Endpoint e) => e.address == endpoint.address && e.addressType == endpoint.addressType)) {
        //Delete Endpoint
        worklist.add(request.deleteEndpoint(receptionId, contactId, endpoint.address, endpoint.addressType));
      }
    }

    //Update
    for(Endpoint endpoint in foundEndpoints) {
      if(persistenceEndpoint.any((Endpoint e) => e.address == endpoint.address && e.addressType == endpoint.addressType)) {
        //Update Endpoint
        worklist.add(request.updateEndpoint(receptionId, contactId, endpoint.address, endpoint.addressType, endpoint.toJson()));
      }
    }
    return Future.wait(worklist);
  }
}

class DistributionsListComponent {
  final Element paranet;
  final Function onChange;
  DistributionList persistentList;
  UListElement ulTo = new UListElement()
    ..classes.add('zebra')
    ..classes.add('distributionlist');

  UListElement ulCc = new UListElement()
    ..classes.add('zebra')
    ..classes.add('distributionlist');

  UListElement ulBcc = new UListElement()
    ..classes.add('zebra')
    ..classes.add('distributionlist');

  SelectElement toPicker = new SelectElement();
  SelectElement ccPicker = new SelectElement();
  SelectElement bccPicker = new SelectElement();

  List<ReceptionColleague> colleagues = new List<ReceptionColleague>();

  DistributionsListComponent(Element this.paranet, Function this.onChange) {
    LabelElement toLabel = new LabelElement()
      ..text = 'To'
      ..title = 'To';
    LabelElement ccLabel = new LabelElement()
      ..text = 'CC'
      ..title = 'Carbon Copy';
    LabelElement bccLabel = new LabelElement()
      ..text = 'BCC'
      ..title = 'Blind Carbon Copy';

    paranet.children.addAll([toLabel,  ulTo,
                             ccLabel,  ulCc,
                             bccLabel, ulBcc]);

    _registerEventListerns();
  }

  void _registerEventListerns() {
    _registerPicker(toPicker, ulTo);
    _registerPicker(ccPicker, ulCc);
    _registerPicker(bccPicker, ulBcc);
  }

  void _registerPicker(SelectElement picker, UListElement ul) {
    picker.onChange.listen((_) {
      if(picker.selectedIndex != 0) {
        OptionElement pickedOption = picker.options[picker.selectedIndex];
        int receptionId = int.parse(pickedOption.dataset['reception_id']);
        int contactId = int.parse(pickedOption.dataset['contact_id']);

        ReceptionContact contact = new ReceptionContact()
          ..receptionId = receptionId
          ..contactId = contactId;

        int index = ul.children.length -1;
        ul.children.insert(index, _makeEndpointRow(contact));

        picker.selectedIndex = 0;
        picker.children.remove(pickedOption);
        _notifyChange();
      }
    });
  }

  void clear() {

  }

  Future load(int receptionId, int contactId) {
    return request.getContactsColleagues(contactId).then((List<ReceptionColleague> list) {
      this.colleagues = list;
    }).then((_) {
      return request.getDistributionList(receptionId, contactId).then((DistributionList list) {
        populateUL(list);
      });
    }).catchError((error) {
      log.error('Tried to load contact ${contactId} in reception: ${receptionId} distributionList but got: ${error}');
    });
  }

  void populateUL(DistributionList list) {
    this.persistentList = list;
    ulTo.children
      ..clear()
      ..addAll(list.to.map(_makeEndpointRow))
      ..add(_makeNewEndpointRow(toPicker, ulTo));

    ulCc.children
      ..clear()
      ..addAll(list.cc.map(_makeEndpointRow))
      ..add(_makeNewEndpointRow(ccPicker, ulCc));

    ulBcc.children
      ..clear()
      ..addAll(list.bcc.map(_makeEndpointRow))
      ..add(_makeNewEndpointRow(bccPicker, ulBcc));
  }

  LIElement _makeNewEndpointRow(SelectElement picker, UListElement ul) {
    LIElement li = new LIElement();

    List<ReceptionContact> allReadyInThelist = _extractReceptionContacts(ul);

    _populatePicker(picker, allReadyInThelist);

    li.children.add(picker);
    return li;
  }

  void _populatePicker(SelectElement picker, List<ReceptionContact> allReadyInThelist) {
    picker.children.clear();
    picker.children.add(new OptionElement(data: 'Vælg'));
    for(var reception in colleagues) {
      for(var contact in reception.contacts) {
        if(!allReadyInThelist.any((rc) => rc.contactId == contact.id && rc.receptionId == reception.id)) {
          String displayedText = '${contact.full_name} (${reception.full_name})';
          picker.children.add(new OptionElement(data: displayedText)
            ..dataset['reception_id'] = reception.id.toString()
            ..dataset['contact_id'] = contact.id.toString());
        }
      }
    }
  }

  LIElement _makeEndpointRow(ReceptionContact contact) {
    LIElement li = new LIElement()
      ..dataset['reception_id'] = contact.receptionId.toString()
      ..dataset['contact_id'] = contact.contactId.toString();

    SpanElement element = new SpanElement();

    bool found = false;
    ReceptionColleague reception = colleagues.firstWhere((ReceptionColleague rc) => rc.id == contact.receptionId, orElse: () => null);
    if(reception != null) {
      Colleague colleague = reception.contacts.firstWhere((Colleague c) => c.id == contact.contactId, orElse: () => null);
      if(colleague != null) {
        found = true;
        element.text = '${colleague.full_name} (${reception.full_name})';
      }
    }

    if(found == false) {
      //This Should not happend.
      element.text = 'Fejl. Person ikke fundet.';
    }

    ImageElement deleteButton = new ImageElement(src: 'image/tp/red_plus.svg')
      ..classes.add('small-button')
      ..text = 'Slet'
      ..onClick.listen((_) {
      li.parent.children.remove(li);
      _notifyChange();

      List<ReceptionContact> allReadyInThelist;

      allReadyInThelist = _extractReceptionContacts(ulTo);
      _populatePicker(toPicker, allReadyInThelist);

      allReadyInThelist = _extractReceptionContacts(ulCc);
      _populatePicker(ccPicker, allReadyInThelist);

      allReadyInThelist = _extractReceptionContacts(ulBcc);
      _populatePicker(bccPicker, allReadyInThelist);

    });

    li.children.addAll([deleteButton, element]);
    return li;
  }

  Future save(int receptionId, int contactId) {
    DistributionList distributionList = new DistributionList();

    distributionList.to  = _extractReceptionContacts(ulTo);
    distributionList.cc  = _extractReceptionContacts(ulCc);
    distributionList.bcc = _extractReceptionContacts(ulBcc);

    return request.updateDistributionList(receptionId, contactId, JSON.encode(distributionList.toJson()));
    //TODO Do something about the response
  }

  List<ReceptionContact> _extractReceptionContacts(UListElement ul) {
    List<ReceptionContact> list = new List<ReceptionContact>();
    for(LIElement li in ul.children) {
      if(li.dataset.containsKey('reception_id') && li.dataset.containsKey('contact_id')) {
        int receptionId = int.parse(li.dataset['reception_id']);
        int contactId = int.parse(li.dataset['contact_id']);
        list.add(new ReceptionContact()
        ..receptionId = receptionId
        ..contactId = contactId);
      }
    }

    return list;
  }

  void _notifyChange() {
    if(onChange != null) {
      onChange();
    }
  }
}
