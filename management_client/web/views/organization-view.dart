library organization.view;

import 'dart:html';
import 'dart:convert';

import '../lib/eventbus.dart';
import '../lib/logger.dart' as log;
import '../lib/model.dart';
import '../lib/request.dart';
import '../notification.dart' as notify;

class OrganizationView {
  static const String viewName = 'organization';
  DivElement element;
  UListElement uiList;
  TextAreaElement inputName, inputBillingtype, inputFlag;
  ButtonElement buttonCreate, buttonSave, buttonDelete;
  SearchInputElement searchBox;
  UListElement ulReceptionList;
  UListElement ulContactList;

  bool createNew = false;

  List<Organization> organizations = new List<Organization>();
  int selectedOrganizationId = 0;

  List<Contact> currentContactList = new List<Contact>();
  List<Reception> currentReceptionList = new List<Reception>();

  OrganizationView(DivElement this.element) {
    searchBox = element.querySelector('#organization-search-box');
    uiList = element.querySelector('#organization-list');
    inputName = element.querySelector('#organization-input-name');
    inputBillingtype = element.querySelector('#organization-input-billingtype');
    inputFlag = element.querySelector('#organization-input-flag');
    buttonSave = element.querySelector('#organization-save');
    buttonCreate = element.querySelector('#organization-create');
    buttonDelete = element.querySelector('#organization-delete');
    ulReceptionList = element.querySelector('#organization-reception-list');
    ulContactList = element.querySelector('#organization-contact-list');

    buttonSave.disabled = true;
    buttonDelete.disabled = true;

    registrateEventHandlers();

    refreshList();
  }

  void registrateEventHandlers() {
    buttonSave.onClick.listen((_) {
      saveChanges();
    });

    buttonCreate.onClick.listen((_) {
      createOrganizationHandler();
    });

    buttonDelete.onClick.listen((_) {
      if (!createNew && selectedOrganizationId > 0) {
        deleteOrganization(selectedOrganizationId).then((_) {
          notify.info('Organisation blev slettet.');

          currentContactList.clear();
          currentReceptionList.clear();
          bus.fire( new OrganizationRemovedEvent(selectedOrganizationId) );
          refreshList();
          clearContent();
          buttonSave.disabled = true;
          buttonDelete.disabled = true;
          selectedOrganizationId = 0;
        }).catchError((error) {
          notify.error('Der skete en fejl i forbindelsen med sletningen.');
          log.error('Failed to delete organization "${selectedOrganizationId}", got "${error}"');
        });
      }
    });

    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
      if (event.containsKey('organization_id')) {
        activateOrganization(event['organization_id']);
      }
    });

    bus.on(ReceptionAddedEvent).listen((ReceptionAddedEvent event) {
      if (event.organizationId == selectedOrganizationId) {
        activateOrganization(selectedOrganizationId);
      }
    });

    bus.on(ReceptionRemovedEvent).listen((ReceptionRemovedEvent event) {
      if (event.organizationId == selectedOrganizationId) {
        activateOrganization(selectedOrganizationId);
      }
    });

    bus.on(ReceptionContactAddedEvent).listen(handleReceptionContactAdded);
    bus.on(ReceptionContactRemovedEvent).listen(handleReceptionContactRemoved);

    searchBox.onInput.listen((_) => performSearch());
  }

  void handleReceptionContactAdded(ReceptionContactAddedEvent event) {
    if (currentReceptionList.any((r) => r.id == event.receptionId)) {
      activateOrganization(selectedOrganizationId);
    }
  }

  void handleReceptionContactRemoved(ReceptionContactRemovedEvent event) {
    if (currentContactList.any((contact) => contact.id == event.contactId)) {
      activateOrganization(selectedOrganizationId);
    }
  }

  void createOrganizationHandler() {
    selectedOrganizationId = 0;
    buttonSave.text = 'Opret';
    buttonSave.disabled = false;
    buttonDelete.disabled = true;
    clearRightBar();
    clearContent();
    createNew = true;
  }

  void clearRightBar() {
    currentContactList.clear();
    currentReceptionList.clear();
    ulContactList.children.clear();
    ulReceptionList.children.clear();
  }

  void clearContent() {
    inputName.value = '';
    inputBillingtype.value = '';
    inputFlag.value = '';
  }

  void performSearch() {
    String searchText = searchBox.value;
    List<Organization> filteredList = organizations.where((Organization org) =>
        org.fullName.toLowerCase().contains(searchText.toLowerCase())).toList();
    renderOrganizationList(filteredList);
  }

  void saveChanges() {
    if (selectedOrganizationId > 0) {
      Map organization = {
        'id': selectedOrganizationId,
        'full_name': inputName.value,
        'billing_type': inputBillingtype.value,
        'flag': inputFlag.value
      };
      String newOrganization = JSON.encode(organization);
      updateOrganization(selectedOrganizationId, newOrganization).then((_) {
        notify.info('Ændringerne blev gemt.');
        refreshList();
      }).catchError((error) {
        notify.error('Der skete en fejl i forbindelse med forsøget på at gemme ændringerne til organisationen.');
        log.error('Tried to update an organizaiton got: $error');
      });
    } else if (createNew) {
      Map organization = {
        'full_name': inputName.value,
        'billing_type': inputBillingtype.value,
        'flag': inputFlag.value
      };
      String newOrganization = JSON.encode(organization);
      createOrganization(newOrganization).then((Map response) {
        notify.info('Organisationen blev oprettet.');
        int organizationId = response['id'];
        refreshList();
        activateOrganization(organizationId);
        bus.fire(new OrganizationAddedEvent());
      }).catchError((error) {
        notify.error('Der skete en fejl, så organisationen blev ikke oprettet.q');
        log.error('Tried to create an new organizaiton got: $error');
      });
    }
  }

  void refreshList() {
    getOrganizationList().then((List<Organization> organizations) {
      organizations.sort();
      this.organizations = organizations;
      renderOrganizationList(organizations);
    }).catchError((error) {
      notify.error('Organisationerne blev ikke hentet da der er sket en fejl.');
      log.error('Tried to fetch organization list, got error: $error');
    });
  }

  void renderOrganizationList(List<Organization> organizations) {
    uiList.children
        ..clear()
        ..addAll(organizations.map(makeOrganizationNode));
  }

  LIElement makeOrganizationNode(Organization organization) {
    return new LIElement()
        ..classes.add('clickable')
        ..dataset['organizationid'] = '${organization.id}'
        ..text = '${organization.fullName}'
        ..onClick.listen((_) {
          activateOrganization(organization.id);
        });
  }

  void highlightOrganizationInList(int id) {
    uiList.children.forEach((LIElement li) => li.classes.toggle('highlightListItem', li.dataset['organizationid'] == '$id'));
  }

  void activateOrganization(int organizationId) {
    getOrganization(organizationId).then((Organization organization) {
      highlightOrganizationInList(organizationId);
      selectedOrganizationId = organizationId;
      createNew = false;
      buttonSave.disabled = false;
      buttonSave.text = 'Gem';
      buttonDelete.disabled = false;
      inputName.value = organization.fullName;
      inputBillingtype.value = organization.billingType;
      inputFlag.value = organization.flag;

      updateReceptionList(selectedOrganizationId);
      updateContactList(selectedOrganizationId);
    }).catchError((error) {
      notify.error('Der skete en fejl i forbindelse med at hente alt information for organisationen.');
      log.error('Tried to activate organization "$organizationId" but gave error: $error');
    });
  }

  void updateReceptionList(int organizationId) {
    getAnOrganizationsReceptionList(organizationId).then((List<Reception> receptions) {
      receptions.sort();
      currentReceptionList = receptions;
      ulReceptionList.children
          ..clear()
          ..addAll(receptions.map(makeReceptionNode));
    }).catchError((error) {
      log.error('Tried to fetch the receptionlist Error: $error');
    });
  }

  LIElement makeReceptionNode(Reception reception) {
    LIElement li = new LIElement()
        ..classes.add('clickable')
        ..text = '${reception.fullName}'
        ..onClick.listen((_) {
          Map event = {
            'window': 'reception',
            'organization_id': reception.organizationId,
            'reception_id': reception.id
          };
          bus.fire(windowChanged, event);
        });
    return li;
  }

  void updateContactList(int organizationId) {
    getOrganizationContactList(organizationId).then((List<Contact> contacts) {
      contacts.sort();
      currentContactList = contacts;
      ulContactList.children
          ..clear()
          ..addAll(contacts.map(makeContactNode));
    }).catchError((error) {
      notify.error('Der skete en fejl i forbindelse med at hente kontakterne tilknyttet organisationen.');
      log.error('Tried to fetch the contactlist from an organization Error: $error');
    });
  }

  LIElement makeContactNode(Contact contact) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${contact.fullName}'
      ..onClick.listen((_) {
        Map event = {
          'window': 'contact',
          'contact_id': contact.id
        };
        bus.fire(windowChanged, event);
      });
    return li;
  }
}
