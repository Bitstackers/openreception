library reception.view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../lib/logger.dart' as log;
import '../lib/model.dart';
import '../lib/request.dart';
import '../lib/eventbus.dart';
import '../lib/view_utilities.dart';
import '../lib/searchcomponent.dart';
import '../notification.dart' as notify;
import '../menu.dart';

class ReceptionView {
  static const String addNewLiClass = 'addnew';
  static const String viewName = 'reception';
  DivElement element;
  TextAreaElement inputFullName, inputShortGreeting, inputProduct, inputGreeting, inputOther,
      inputCostumerstype, inputReceptionNumber;
  ButtonElement buttonDialplan;
  CheckboxInputElement inputEnabled;
  ButtonElement buttonSave, buttonCreate, buttonDelete;
  UListElement ulAddresses, ulAlternatenames, ulBankinginformation,
      ulSalesCalls, ulEmailaddresses, ulHandlings, ulOpeninghours,
      ulRegistrationnumbers, ulTelephonenumbers, ulWebsites;
  SearchInputElement searchBox;
  UListElement uiReceptionList;
  UListElement ulContactList;
  DivElement organizationOuterSelector;

  List<Reception> receptions = new List<Reception>();

  SearchComponent<Organization> SC;
  int selectedReceptionId = 0,
      currentOrganizationId = 0;

  ReceptionView(DivElement this.element) {
    searchBox = element.querySelector('#reception-search-box');
    uiReceptionList = element.querySelector('#reception-list');
    ulContactList = element.querySelector('#reception-contact-list');

    inputFullName = element.querySelector('#reception-input-name');
    inputProduct = element.querySelector('#reception-input-product');
    inputOther = element.querySelector('#reception-input-other');
    inputCostumerstype = element.querySelector('#reception-input-customertype');
    inputShortGreeting = element.querySelector('#reception-input-shortgreeting');
    inputGreeting = element.querySelector('#reception-input-greeting');
    inputEnabled = element.querySelector('#reception-input-enabled');
    inputReceptionNumber = element.querySelector(
        '#reception-input-receptionnumber');
    buttonDialplan = element.querySelector('#reception-button-dialplan');

    ulAddresses = element.querySelector('#reception-list-addresses');
    ulAlternatenames = element.querySelector('#reception-list-alternatenames');
    ulBankinginformation = element.querySelector(
        '#reception-list-bankinginformation');
    ulSalesCalls = element.querySelector(
        '#reception-list-salescalls');
    ulEmailaddresses = element.querySelector('#reception-list-emailaddresses');
    ulHandlings = element.querySelector('#reception-list-handlings');
    ulOpeninghours = element.querySelector('#reception-list-openinghours');
    ulRegistrationnumbers = element.querySelector(
        '#reception-list-registrationnumbers');
    ulTelephonenumbers = element.querySelector(
        '#reception-list-telephonenumbers');
    ulWebsites = element.querySelector('#reception-list-websites');

    buttonSave = element.querySelector('#reception-save');
    buttonCreate = element.querySelector('#reception-create');
    buttonDelete = element.querySelector('#reception-delete');

    organizationOuterSelector = element.querySelector(
        '#reception-organization-selector');

    SC = new SearchComponent<Organization>(organizationOuterSelector,
        'reception-organization-searchbox')
        ..listElementToString = organizationToSearchboxString
        ..searchFilter = organizationSearchHandler
        ..searchPlaceholder = 'Søg...';

    fillSearchComponent();

    buttonSave.disabled = true;
    buttonDelete.disabled = true;

    registrateEventHandlers();

    refreshList();
  }

  void fillSearchComponent() {
    getOrganizationList().then((List<Organization> list) {
      list.sort();
      SC.updateSourceList(list);
    });
  }

  String organizationToSearchboxString(Organization organization, String searchterm) {
    return '${organization.fullName}';
  }

  bool organizationSearchHandler(Organization organization, String searchTerm) {
    return organization.fullName.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void registrateEventHandlers() {
    buttonSave.onClick.listen((_) {
      saveChanges();
    });

    buttonCreate.onClick.listen((_) => createReceptionClickHandler());

    buttonDelete.onClick.listen((_) => deleteCurrentReception());

    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
      if (event.containsKey('organization_id') && event.containsKey(
          'reception_id')) {
        activateReception(event['organization_id'], event['reception_id']);
      }
    });

    bus.on(OrganizationAddedEvent).listen((OrganizationAddedEvent event) {
      fillSearchComponent();
    });

    bus.on(OrganizationRemovedEvent).listen((OrganizationRemovedEvent event) {
      fillSearchComponent();
    });

    bus.on(ReceptionContactAddedEvent).listen((ReceptionContactAddedEvent event) {
      if (selectedReceptionId == event.receptionId) {
        activateReception(currentOrganizationId, selectedReceptionId);
      }
    });

    bus.on(ReceptionContactRemovedEvent).listen((ReceptionContactRemovedEvent event) {
      if (selectedReceptionId == event.receptionId) {
        activateReception(currentOrganizationId, selectedReceptionId);
      }
    });

    searchBox.onInput.listen((_) => performSearch());

    buttonDialplan.onClick.listen((_) => goToDialplan());
  }

  void performSearch() {
    String searchText = searchBox.value;
    List<Reception> filteredList = receptions.where((Reception recep) =>
        recep.fullName.toLowerCase().contains(searchText.toLowerCase())).toList();
    renderReceptionList(filteredList);
  }

  void renderReceptionList(List<Reception> receptions) {
    uiReceptionList.children
        ..clear()
        ..addAll(receptions.map(makeReceptionNode));
  }

  void createReceptionClickHandler() {
    selectedReceptionId = 0;
    currentOrganizationId = 0;

    buttonDelete.disabled = true;
    buttonSave.disabled = false;
    buttonSave.text = 'Opret';

    //Clear all fields.
    clearContent();
    ulContactList.children.clear();
  }

  void clearContent() {
    buttonDialplan.disabled = true;
    inputFullName.value = '';
    inputEnabled.checked = true;
    inputReceptionNumber.value = '';
    inputCostumerstype.value = '';
    inputShortGreeting.value = '';
    inputGreeting.value = '';
    inputOther.value = '';
    inputProduct.value = '';
    fillList(ulAddresses, new List<String>());
    fillList(ulAlternatenames, new List<String>());
    fillList(ulBankinginformation, new List<String>());
    fillList(ulSalesCalls, new List<String>());
    fillList(ulEmailaddresses, new List<String>());
    fillList(ulHandlings, new List<String>());
    fillList(ulOpeninghours, new List<String>());
    fillList(ulRegistrationnumbers, new List<String>());
    fillList(ulTelephonenumbers, new List<String>());
    fillList(ulWebsites, new List<String>());
  }

  void goToDialplan() {
    if (selectedReceptionId != null && selectedReceptionId > 0) {
      bus.fire(new WindowChangedEvent.DialplanWithReception(selectedReceptionId));
    }
  }

  void deleteCurrentReception() {
    if (selectedReceptionId > 0) {
      deleteReception(selectedReceptionId).then((_) {
        notify.info('Sletning af receptionen gik godt.');
        bus.fire(new ReceptionRemovedEvent(currentOrganizationId, selectedReceptionId));
        selectedReceptionId = 0;
        currentOrganizationId = 0;
        clearContent();
        refreshList();
      }).catchError((error) {
        notify.error('Der skete en fejl i forbindelse med sletningen af receptionen. Fejl: ${error}');
        log.error('Failed to delete reception orgId: "${currentOrganizationId}" recId: "${selectedReceptionId}" got "${error}"');
      });
    }
  }

  void saveChanges() {
    if (selectedReceptionId > 0) {
      Reception updatedReception = extractValues();

      updateReception(selectedReceptionId, JSON.encode(updatedReception)).then((_) {
        //Show a message that tells the user, that the changes went threw.
        notify.info('Receptionens ændringer er gemt.');
        refreshList();
      }).catchError((error, stack) {
        notify.error('Der skete en fejl da receptionen skulle gemmes. ${error}');
        log.error('Tried to update reception ${selectedReceptionId} but got "${error}" "${stack}"');
      });
    } else if (selectedReceptionId == 0 && currentOrganizationId == 0) {
      Reception newReception = extractValues();
      if (SC.currentElement != null) {
        int organizationId = SC.currentElement.id;
        createReception(organizationId, JSON.encode(newReception)).then((Map data) {
          notify.info('Receptionen blev oprettet.');
          int receptionId = data['id'];
          bus.fire( new ReceptionAddedEvent(organizationId) );
          return refreshList().then((_) {
            return activateReception(organizationId, receptionId);
          });
        }).catchError((error) {
          notify.error('Der skete en fejl, så receptionen blev ikke oprettet.');
          log.error('Tried to create a new reception but got "${error}"');
        });
      }
    }
  }

  Reception extractValues() {
    return new Reception()
        ..organizationId = currentOrganizationId
        ..fullName = inputFullName.value
        ..enabled = inputEnabled.checked
        ..receptionNumber = inputReceptionNumber.value

        ..customertype = inputCostumerstype.value
        ..shortGreeting = inputShortGreeting.value
        ..greeting = inputGreeting.value
        ..other = inputOther.value
        ..product = inputProduct.value

        ..addresses = getListValues(ulAddresses)
        ..alternateNames = getListValues(ulAlternatenames)
        ..bankinginformation = getListValues(ulBankinginformation)
        ..salesCalls = getListValues(ulSalesCalls)
        ..emailaddresses = getListValues(ulEmailaddresses)
        ..handlings = getListValues(ulHandlings)
        ..openinghours = getListValues(ulOpeninghours)
        ..registrationnumbers = getListValues(ulRegistrationnumbers)
        ..telephonenumbers = getListValues(ulTelephonenumbers)
        ..websites = getListValues(ulWebsites);
  }

  Future refreshList() {
    return getReceptionList().then((List<Reception> receptions) {
      receptions.sort();
      this.receptions = receptions;
      performSearch();
    }).catchError((error) {
      log.error(
          'Failed to refreshing the list of receptions in reception window.');
    });
  }

  LIElement makeReceptionNode(Reception reception) {
    return new LIElement()
        ..classes.add('clickable')
        ..dataset['receptionid'] = '${reception.id}'
        ..text = reception.fullName
        ..onClick.listen((_) {
          activateReception(reception.organizationId, reception.id);
        });
  }

  void highlightContactInList(int id) {
    uiReceptionList.children.forEach((LIElement li) =>
        li.classes.toggle('highlightListItem', li.dataset['receptionid'] == '$id'));
  }

  void activateReception(int organizationId, int receptionId) {
    currentOrganizationId = organizationId;
    selectedReceptionId = receptionId;

    buttonDelete.disabled = false;
    buttonSave.disabled = false;
    buttonSave.text = 'Gem';

    SC.selectElement(null, (Organization listItem, _) {
      return listItem.id == organizationId;
    });

    if (receptionId > 0) {
      getReception(selectedReceptionId).then((Reception response) {
        buttonDialplan.disabled = false;

        highlightContactInList(receptionId);

        inputFullName.value = response.fullName;
        inputEnabled.checked = response.enabled;
        inputReceptionNumber.value = response.receptionNumber;
        inputCostumerstype.value = response.customertype;
        inputShortGreeting.value = response.shortGreeting;
        inputGreeting.value = response.greeting;
        inputOther.value = response.other;
        inputProduct.value = response.product;
        fillList(ulAddresses, response.addresses);
        fillList(ulAlternatenames, response.alternateNames);
        fillList(ulBankinginformation, response.bankinginformation);
        fillList(ulSalesCalls, response.salesCalls);
        fillList(ulEmailaddresses, response.emailaddresses);
        fillList(ulHandlings, response.handlings);
        fillList(ulOpeninghours, response.openinghours);
        fillList(ulRegistrationnumbers, response.registrationnumbers);
        fillList(ulTelephonenumbers, response.telephonenumbers);
        fillList(ulWebsites, response.websites);
      });

      updateContactList(receptionId);
    } else {
      clearContent();
      updateContactList(receptionId);
    }
  }

  void updateContactList(int receptionId) {
    getReceptionContactList(receptionId).then((List<Contact> contacts) {
      contacts.sort();
      ulContactList.children
          ..clear()
          ..addAll(contacts.map((Contact contact) => makeContactNode(contact, receptionId)));
    }).catchError((error) {
      log.error('Tried to fetch the contactlist from an reception Error: $error');
    });
  }

  LIElement makeContactNode(Contact contact, int receptionId) {
    LIElement li = new LIElement();
    li
        ..classes.add('clickable')
        ..text = contact.fullName
        ..onClick.listen((_) {
          Map event = {
            'window': 'contact',
            'contact_id': contact.id,
            'reception_id': receptionId
          };
        bus.fire(windowChanged, event);
      });
    return li;
  }
}
