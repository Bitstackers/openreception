library reception.view;

import 'dart:async';
import 'dart:html';

import '../lib/logger.dart' as log;
import '../lib/eventbus.dart';
import '../lib/view_utilities.dart';
import '../lib/searchcomponent.dart';
import '../notification.dart' as notify;
import '../menu.dart';
import '../lib/controller.dart' as Controller;

import 'package:openreception_framework/model.dart' as ORModel;

class ReceptionView {
  static const String viewName = 'reception';

  final Controller.Contact _contactController;
  final Controller.Organization _organizationController;
  final Controller.Reception _receptionController;

  DivElement element;
  TextAreaElement inputFullName, inputShortGreeting, inputProduct, inputGreeting, inputOther,
      inputCostumerstype, inputReceptionNumber, extradataUrl;
  ButtonElement buttonDialplan;
  CheckboxInputElement inputEnabled;
  ButtonElement buttonSave, buttonCreate, buttonDelete;
  UListElement ulAddresses, ulAlternatenames, ulBankinginformation,
      ulSalesCalls, ulEmailaddresses, ulHandlings, ulOpeninghours,
      ulRegistrationNumbers, ulTelephonenumbers, ulWebsites;
  SearchInputElement searchBox;
  UListElement uiReceptionList;
  UListElement ulContactList;
  DivElement organizationOuterSelector;

  List<ORModel.Reception> receptions = new List<ORModel.Reception>();

  SearchComponent<ORModel.Organization> SC;
  int selectedReceptionId   = 0,
      currentOrganizationId = 0;
  bool createNew = false;

  ReceptionView(DivElement this.element, Controller.Contact this._contactController,
                    Controller.Organization this._organizationController,
                        Controller.Reception this._receptionController) {
    searchBox       = element.querySelector('#reception-search-box');
    uiReceptionList = element.querySelector('#reception-list');
    ulContactList   = element.querySelector('#reception-contact-list');

    inputFullName        = element.querySelector('#reception-input-name');
    inputProduct         = element.querySelector('#reception-input-product');
    inputOther           = element.querySelector('#reception-input-other');
    inputCostumerstype   = element.querySelector('#reception-input-customertype');
    inputShortGreeting   = element.querySelector('#reception-input-shortgreeting');
    inputGreeting        = element.querySelector('#reception-input-greeting');
    inputEnabled         = element.querySelector('#reception-input-enabled');
    inputReceptionNumber = element.querySelector('#reception-input-receptionnumber');
    extradataUrl         = element.querySelector('#reception-input-extradataurl');
    buttonDialplan       = element.querySelector('#reception-button-dialplan');

    ulAddresses           = element.querySelector('#reception-list-addresses');
    ulAlternatenames      = element.querySelector('#reception-list-alternatenames');
    ulBankinginformation  = element.querySelector('#reception-list-bankinginformation');
    ulSalesCalls          = element.querySelector('#reception-list-salescalls');
    ulEmailaddresses      = element.querySelector('#reception-list-emailaddresses');
    ulHandlings           = element.querySelector('#reception-list-handlings');
    ulOpeninghours        = element.querySelector('#reception-list-openinghours');
    ulRegistrationNumbers = element.querySelector('#reception-list-registrationnumbers');
    ulTelephonenumbers    = element.querySelector('#reception-list-telephonenumbers');
    ulWebsites            = element.querySelector('#reception-list-websites');

    buttonSave   = element.querySelector('#reception-save');
    buttonCreate = element.querySelector('#reception-create');
    buttonDelete = element.querySelector('#reception-delete');

    organizationOuterSelector = element.querySelector('#reception-organization-selector');

    SC = new SearchComponent<ORModel.Organization>(organizationOuterSelector, 'reception-organization-searchbox')
      ..selectedElementChanged = selectedElementChanged
      ..listElementToString = organizationToSearchboxString
      ..searchFilter = organizationSearchHandler
      ..searchPlaceholder = 'Søg...';

    fillSearchComponent();

    disabledDeleteButton();
    disabledSaveButton();

    registerEventHandlers();

    refreshList();
  }

  void fillSearchComponent() {
    _organizationController.list().then((Iterable<ORModel.Organization> orgs) {

      int compareTo (ORModel.Organization org1, ORModel.Organization org2) => org1.fullName.compareTo(org2.fullName);

      List list = orgs.toList()..sort(compareTo);
      SC.updateSourceList(list);
    });
  }

  String organizationToSearchboxString(ORModel.Organization organization, String searchterm) {
    return '${organization.fullName}';
  }

  bool organizationSearchHandler(ORModel.Organization organization, String searchTerm) {
    return organization.fullName.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void selectedElementChanged(ORModel.Organization organization) {
    currentOrganizationId = organization.id;
    OnContentChange();
  }

  void registerEventHandlers() {
    buttonSave.onClick.listen((_) {
      saveChanges();
    });

    buttonCreate.onClick.listen((_) => createReceptionClickHandler());
    buttonDelete.onClick.listen((_) => deleteCurrentReception());

    bus.on(WindowChanged).listen((WindowChanged event) {
      element.classes.toggle('hidden', event.window != viewName);
      if (event.data.containsKey('organization_id') &&
          event.data.containsKey('reception_id')) {
        activateReception(event.data['organization_id'], event.data['reception_id']);
      }
    });

    bus.on(ReceptionAddedEvent).listen((ReceptionAddedEvent event) {
      refreshList();
    });

    bus.on(ReceptionRemovedEvent).listen((ReceptionRemovedEvent event) {
      refreshList();
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

    //Listen to content elements for changes.
    buttonDialplan.onInput.listen((_) => OnContentChange());
    inputFullName.onInput.listen((_) => OnContentChange());
    inputEnabled.onChange.listen((_) => OnContentChange());
    inputReceptionNumber.onInput.listen((_) => OnContentChange());
    inputCostumerstype.onInput.listen((_) => OnContentChange());
    inputShortGreeting.onInput.listen((_) => OnContentChange());
    inputGreeting.onInput.listen((_) => OnContentChange());
    inputOther.onInput.listen((_) => OnContentChange());
    inputProduct.onInput.listen((_) => OnContentChange());
    extradataUrl.onInput.listen((_) => OnContentChange());
  }

  void enabledSaveButton() {
    buttonSave.disabled = false;
  }

  void disabledSaveButton() {
    buttonSave.disabled = true;
  }

  void enabledDeleteButton() {
    buttonDelete.disabled = false;
  }

  void disabledDeleteButton() {
    buttonDelete.disabled = true;
  }

  void OnContentChange() {
    if(createNew || selectedReceptionId > 0) {
      inputFullName.value.trim() == '' ? disabledSaveButton() : enabledSaveButton();
    }
  }

  void performSearch() {
    String searchText = searchBox.value;
    List<ORModel.Reception> filteredList = receptions.where((ORModel.Reception recep) =>
        recep.fullName.toLowerCase().contains(searchText.toLowerCase())).toList();
    renderReceptionList(filteredList);
  }

  void renderReceptionList(List<ORModel.Reception> receptions) {
    uiReceptionList.children
      ..clear()
      ..addAll(receptions.map(makeReceptionNode));
  }

  void createReceptionClickHandler() {
    selectedReceptionId = 0;
    currentOrganizationId = 0;
    createNew = true;

    disabledDeleteButton();
    disabledSaveButton();
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
    extradataUrl.value = '';
    fillList(ulAddresses, new List<String>(), onChange: OnContentChange);
    fillList(ulAlternatenames, new List<String>(), onChange: OnContentChange);
    fillList(ulBankinginformation, new List<String>(), onChange: OnContentChange);
    fillList(ulSalesCalls, new List<String>(), onChange: OnContentChange);
    fillList(ulEmailaddresses, new List<String>(), onChange: OnContentChange);
    fillList(ulHandlings, new List<String>(), onChange: OnContentChange);
    fillList(ulOpeninghours, new List<String>(), onChange: OnContentChange);
    fillList(ulRegistrationNumbers, new List<String>(), onChange: OnContentChange);
    fillList(ulTelephonenumbers, new List<String>(), onChange: OnContentChange);
    fillList(ulWebsites, new List<String>(), onChange: OnContentChange);
  }

  void goToDialplan() {
    if (selectedReceptionId != null && selectedReceptionId > 0) {
      Map data = {
        'reception_id': selectedReceptionId
      };
      bus.fire(new WindowChanged(Menu.DIALPLAN_WINDOW, data));
    }
  }

  void deleteCurrentReception() {
    if (selectedReceptionId > 0) {
      _receptionController.remove(selectedReceptionId).then((_) {
        notify.info('Sletning af receptionen gik godt.');
        bus.fire(new ReceptionRemovedEvent(currentOrganizationId, selectedReceptionId));
        selectedReceptionId = 0;
        currentOrganizationId = 0;
        clearContent();
      }).catchError((error) {
        notify.error('Der skete en fejl i forbindelse med sletningen af receptionen. Fejl: ${error}');
        log.error('Failed to delete reception orgId: "${currentOrganizationId}" recId: "${selectedReceptionId}" got "${error}"');
      });
    }
  }

  void saveChanges() {

    if (selectedReceptionId > 0) {
      ORModel.Reception updatedReception = extractValues();

      _receptionController.update(updatedReception).then((_) {
        //Show a message that tells the user, that the changes went threw.
        notify.info('Receptionens ændringer er gemt.');
        refreshList();
      }).catchError((error, stack) {
        notify.error('Der skete en fejl da receptionen skulle gemmes. ${error}');
        log.error('Tried to update reception ${selectedReceptionId} but got "${error}" "${stack}"');
      });
    } else if (createNew && selectedReceptionId == 0) {
      ORModel.Reception newReception = extractValues();
      print(SC.currentElement);
      if (SC.currentElement != null) {
        newReception.organizationId = SC.currentElement.id;
        _receptionController.create(newReception).then((ORModel.Reception createdReception) {

          notify.info('Receptionen blev oprettet.');

          bus.fire( new ReceptionAddedEvent(createdReception.organizationId) );
          return refreshList().then((_) {
            return activateReception(createdReception.organizationId, createdReception.ID);
          });
        }).catchError((error) {
          notify.error('Der skete en fejl, så receptionen blev ikke oprettet.');
          log.error('Tried to create a new reception but got "${error}"');
        });
      }
    }
  }

  ORModel.Reception extractValues() {
    return new ORModel.Reception.empty()
      ..ID = selectedReceptionId
      ..organizationId = currentOrganizationId
      ..fullName = inputFullName.value
      ..enabled = inputEnabled.checked
      ..dialplan = inputReceptionNumber.value

      ..customerTypes = [inputCostumerstype.value]
      ..shortGreeting = inputShortGreeting.value
      ..greeting = inputGreeting.value
      ..otherData = inputOther.value
      ..product = inputProduct.value
      ..extraData = Uri.parse(extradataUrl.value)
      ..addresses = getListValues(ulAddresses)
      ..alternateNames = getListValues(ulAlternatenames)
      ..bankingInformation = getListValues(ulBankinginformation)
      ..salesMarketingHandling = getListValues(ulSalesCalls)
      ..emailAddresses = getListValues(ulEmailaddresses)
      ..handlingInstructions = getListValues(ulHandlings)
      ..openingHours = getListValues(ulOpeninghours)
      ..vatNumbers = getListValues(ulRegistrationNumbers)
      //TODO: Convert these to types.
      //..telephoneNumbers = getListValues(ulTelephonenumbers)
      ..websites = getListValues(ulWebsites);
  }

  Future refreshList() {
    return _receptionController.list().then((Iterable<ORModel.Reception> receptions) {

      int compareTo (ORModel.Reception r1, ORModel.Reception r2) => r1.fullName.compareTo(r2.fullName);

      List list = receptions.toList()..sort(compareTo);
      this.receptions = list;
      performSearch();
    });
  }

  LIElement makeReceptionNode(ORModel.Reception reception) {
    return new LIElement()
      ..classes.add('clickable')
      ..dataset['receptionid'] = '${reception.ID}'
      ..text = reception.fullName
      ..onClick.listen((_) {
        activateReception(reception.organizationId, reception.ID);
      });
  }

  void highlightContactInList(int id) {
    uiReceptionList.children.forEach((LIElement li) =>
        li.classes.toggle('highlightListItem', li.dataset['receptionid'] == '$id'));
  }

  void activateReception(int organizationId, int receptionId) {
    currentOrganizationId = organizationId;
    selectedReceptionId = receptionId;

    disabledSaveButton();
    enabledDeleteButton();
    buttonSave.text = 'Gem';
    createNew = false;

    SC.selectElement(null, (ORModel.Organization listItem, _) {
      return listItem.id == organizationId;
    });

    if (receptionId > 0) {
      _receptionController.get(selectedReceptionId).then((ORModel.Reception response) {
        buttonDialplan.disabled = false;

        highlightContactInList(receptionId);

        inputFullName.value = response.fullName;
        inputEnabled.checked = response.enabled;
        inputReceptionNumber.value = response.dialplan;

        //TODO: Listify
        inputCostumerstype.value = response.customerTypes.isNotEmpty ? response.customerTypes.first : '';
        inputShortGreeting.value = response.shortGreeting;
        inputGreeting.value = response.greeting;
        inputOther.value = response.otherData;
        inputProduct.value = response.product;
        extradataUrl.value = response.extraData.toString();
        fillList(ulAddresses, response.addresses, onChange: OnContentChange);
        fillList(ulAlternatenames, response.alternateNames, onChange: OnContentChange);
        fillList(ulBankinginformation, response.bankingInformation, onChange: OnContentChange);
        fillList(ulSalesCalls, response.salesMarketingHandling, onChange: OnContentChange);
        fillList(ulEmailaddresses, response.emailAddresses, onChange: OnContentChange);
        fillList(ulHandlings, response.handlingInstructions, onChange: OnContentChange);
        fillList(ulOpeninghours, response.openingHours, onChange: OnContentChange);
        fillList(ulRegistrationNumbers, response.vatNumbers, onChange: OnContentChange);
        //TODO: Make visual representation of this one.
        //fillList(ulTelephonenumbers, response.telephoneNumbers, onChange: OnContentChange);
        fillList(ulWebsites, response.websites, onChange: OnContentChange);
      });

      updateContactList(receptionId);
    } else {
      clearContent();
      updateContactList(receptionId);
    }
  }

  void updateContactList(int receptionId) {
    _contactController.list(receptionId).then((Iterable<ORModel.Contact> contacts) {

      int compareTo(ORModel.Contact c1, ORModel.Contact c2) => c1.fullName.compareTo(c2.fullName);


      List list = contacts.toList()..sort(compareTo);
      ulContactList.children
          ..clear()
          ..addAll(contacts.map((ORModel.Contact contact) => makeContactNode(contact, receptionId)));
    });
  }

  LIElement makeContactNode(ORModel.Contact contact, int receptionId) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = contact.fullName
      ..onClick.listen((_) {
        Map data = {
          'contact_id': contact.ID,
          'reception_id': receptionId
        };
        bus.fire(new WindowChanged(Menu.CONTACT_WINDOW, data));
      });
    return li;
  }
}
