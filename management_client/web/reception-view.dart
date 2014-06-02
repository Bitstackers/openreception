library reception_view;

import 'dart:async';
import 'dart:html';

import 'lib/logger.dart' as log;
import 'lib/model.dart';
import 'lib/request.dart';
import 'lib/eventbus.dart';
import 'lib/view_utilities.dart';
import 'lib/searchcomponent.dart';
import 'notification.dart' as notify;
import 'menu.dart';

class ReceptionView {
  String addNewLiClass = 'addnew';
  String viewName = 'reception';
  DivElement element;
  InputElement inputFullName, inputShortGreeting, inputProduct, inputGreeting, inputOther,
      inputCostumerstype, inputReceptionNumber;
  ButtonElement buttonDialplan;
  CheckboxInputElement inputEnabled;
  ButtonElement buttonSave, buttonCreate, buttonDelete;
  UListElement ulAddresses, ulAlternatenames, ulBankinginformation,
      ulCrapcallhandling, ulEmailaddresses, ulHandlings, ulOpeninghours,
      ulRegistrationnumbers, ulTelephonenumbers, ulWebsites;
  SearchInputElement searchBox;
  UListElement uiReceptionList;
  UListElement ulContactList;
  DivElement organizationOuterSelector;

  List<Reception> receptions = [];

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
    ulCrapcallhandling = element.querySelector(
        '#reception-list-crapcallhandling');
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
        ..searchFilter = organizationSearchHandler;

    fillSearchComponent();

    buttonSave.disabled = true;
    buttonDelete.disabled = true;

    registrateEventHandlers();

    refreshList();
  }

  void fillSearchComponent() {
    getOrganizationList().then((List<Organization> list) {
      list.sort((a, b) => a.full_name.compareTo(b.full_name));
      SC.updateSourceList(list);
    });
  }

  String organizationToSearchboxString(Organization organization, String searchterm) {
    return '${organization.full_name}';
  }

  bool organizationSearchHandler(Organization organization, String searchTerm) {
    return organization.full_name.toLowerCase().contains(searchTerm.toLowerCase());
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

    bus.on(Invalidate.organizationAdded).listen((int id) {
      fillSearchComponent();
    });

    bus.on(Invalidate.organizationRemoved).listen((int id) {
      fillSearchComponent();
    });

    bus.on(Invalidate.receptionContactAdded).listen((Map event) {
      int receptionId = event['receptionId'];
      if (selectedReceptionId == receptionId) {
        activateReception(currentOrganizationId, selectedReceptionId);
      }
    });

    bus.on(Invalidate.receptionContactRemoved).listen((Map event) {
      int receptionId = event['receptionId'];
      if (selectedReceptionId == receptionId) {
        activateReception(currentOrganizationId, selectedReceptionId);
      }
    });

    searchBox.onInput.listen((_) => performSearch());

    buttonDialplan.onClick.listen((_) => goToDialplan());
  }

  void performSearch() {
    String searchText = searchBox.value;
    List<Reception> filteredList = receptions.where((Reception recep) =>
        recep.full_name.toLowerCase().contains(searchText.toLowerCase())).toList();
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
    inputGreeting.value = '';
    inputOther.value = '';
    inputProduct.value = '';
    fillList(ulAddresses, []);
    fillList(ulAlternatenames, []);
    fillList(ulBankinginformation, []);
    fillList(ulCrapcallhandling, []);
    fillList(ulEmailaddresses, []);
    fillList(ulHandlings, []);
    fillList(ulOpeninghours, []);
    fillList(ulRegistrationnumbers, []);
    fillList(ulTelephonenumbers, []);
    fillList(ulWebsites, []);
  }

  void goToDialplan() {
    if (selectedReceptionId != null && selectedReceptionId > 0) {
      Map event = {
        'window': Menu.DIALPLAN_WINDOW,
        'receptionid': selectedReceptionId
      };
      bus.fire(windowChanged, event);
    }
  }

  void deleteCurrentReception() {
    if (currentOrganizationId > 0 && selectedReceptionId > 0) {
      deleteReception(currentOrganizationId, selectedReceptionId).then((_) {
        Map event = {
          'organizationId': currentOrganizationId,
          'receptionId': selectedReceptionId
        };
        notify.info('Sletning af receptionen gik godt.');
        bus.fire(Invalidate.receptionRemoved, event);
        selectedReceptionId = 0;
        currentOrganizationId = 0;
        clearContent();
        refreshList();
      }).catchError((error) {
        notify.error('Der skete en fejl i forbindelse med sletningen af receptionen.');
        log.error('Failed to delete reception orgId: "${currentOrganizationId}" recId: "${selectedReceptionId}" got "${error}"');
      });
    }
  }

  void saveChanges() {
    if (selectedReceptionId > 0) {
      Reception updatedReception = extractValues();

      updateReception(currentOrganizationId, selectedReceptionId,
          updatedReception.toJson()).then((_) {
        //Show a message that tells the user, that the changes went threw.
        refreshList();
      });
    } else if (selectedReceptionId == 0 && currentOrganizationId == 0) {
      Reception newReception = extractValues();
      if (SC.currentElement != null) {
        int organizationId = SC.currentElement.id;
        createReception(organizationId, newReception.toJson()).then((Map data) {
          notify.info('Receptionen blev oprettet.');
          int receptionId = data['id'];
          bus.fire(Invalidate.receptionAdded, organizationId);
          return refreshList().then((_) {
            return activateReception(organizationId, receptionId);
          });
        }).catchError((error) {
          notify.error('Der skete en fejl, så receptionen blev ikke oprettet.');
          log.error('Tried to create a new reception but got "$error"');
        });
      }
    }
  }

  Reception extractValues() {
    return new Reception()
        ..organization_id = currentOrganizationId
        ..full_name = inputFullName.value
        ..enabled = inputEnabled.checked
        ..number = inputReceptionNumber.value

        ..customertype = inputCostumerstype.value
        ..greeting = inputGreeting.value
        ..other = inputOther.value
        ..product = inputProduct.value

        ..addresses = getListValues(ulAddresses)
        ..alternatenames = getListValues(ulAlternatenames)
        ..bankinginformation = getListValues(ulBankinginformation)
        ..crapcallhandling = getListValues(ulCrapcallhandling)
        ..emailaddresses = getListValues(ulEmailaddresses)
        ..handlings = getListValues(ulHandlings)
        ..openinghours = getListValues(ulOpeninghours)
        ..registrationnumbers = getListValues(ulRegistrationnumbers)
        ..telephonenumbers = getListValues(ulTelephonenumbers)
        ..websites = getListValues(ulWebsites);
  }

  Future refreshList() {
    return getReceptionList().then((List<Reception> receptions) {
      receptions.sort((a, b) => a.full_name.compareTo(b.full_name));
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
        ..value = reception.id //TODO Er den brugt?
        ..text = '${reception.full_name}'
        ..onClick.listen((_) {
          activateReception(reception.organization_id, reception.id);
        });
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

    if (organizationId > 0 && receptionId > 0) {
      getReception(currentOrganizationId, selectedReceptionId).then((Reception
          response) {
        buttonDialplan.disabled = false;

        inputFullName.value = response.full_name;
        inputEnabled.checked = response.enabled;
        inputReceptionNumber.value = response.number;

        inputCostumerstype.value = response.customertype;
        inputGreeting.value = response.greeting;
        inputOther.value = response.other;
        inputProduct.value = response.product;
        fillList(ulAddresses, response.addresses);
        fillList(ulAlternatenames, response.alternatenames);
        fillList(ulBankinginformation, response.bankinginformation);
        fillList(ulCrapcallhandling, response.crapcallhandling);
        fillList(ulEmailaddresses, response.emailaddresses);
        fillList(ulHandlings, response.handlings);
        fillList(ulOpeninghours, response.openinghours);
        fillList(ulRegistrationnumbers, response.registrationnumbers);
        fillList(ulTelephonenumbers, response.telephonenumbers);
        fillList(ulWebsites, response.websites);
      });

      updateContactList(receptionId);
    } else {
      inputFullName.value = '';
      inputEnabled.checked = false;

      inputCostumerstype.value = '';
      inputGreeting.value = '';
      inputOther.value = '';
      inputProduct.value = '';
      fillList(ulAddresses, []);
      fillList(ulAlternatenames, []);
      fillList(ulBankinginformation, []);
      fillList(ulCrapcallhandling, []);
      fillList(ulEmailaddresses, []);
      fillList(ulHandlings, []);
      fillList(ulOpeninghours, []);
      fillList(ulRegistrationnumbers, []);
      fillList(ulTelephonenumbers, []);
      fillList(ulWebsites, []);
      updateContactList(receptionId);
    }
  }

  void updateContactList(int receptionId) {
    getReceptionContactList(receptionId).then((List<CustomReceptionContact>
        contacts) {
      ulContactList.children
          ..clear()
          ..addAll(contacts.map(makeContactNode));
    }).catchError((error) {
      log.error('Tried to fetch the contactlist from an reception Error: $error'
          );
    });
  }

  LIElement makeContactNode(CustomReceptionContact contact) {
    LIElement li = new LIElement();
    li
        ..classes.add('clickable')
        ..text = '${contact.fullName}'
        ..onClick.listen((_) {
          Map event = {
            'window': 'contact',
            'contact_id': contact.contactId
          };
          bus.fire(windowChanged, event);
        });
    return li;
  }
}
