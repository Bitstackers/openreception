library organization.view;

import 'dart:html';
import 'dart:convert';

import '../lib/eventbus.dart';
import '../lib/logger.dart' as log;
import '../lib/model.dart';
import '../lib/request.dart';
import '../notification.dart' as notify;
import '../menu.dart';
import 'package:openreception_framework/model.dart' as ORModel;

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

  List<ORModel.Organization> organizations = new List<ORModel.Organization>();
  int selectedOrganizationId;

  List<ORModel.Contact> currentContactList = new List<ORModel.Contact>();
  List<ORModel.Reception> currentReceptionList = new List<ORModel.Reception>();

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

    disableDeleteButton();
    disableSaveButton();

    registerEventHandlers();

    refreshList();
  }

  void registerEventHandlers() {
    buttonSave.onClick.listen((_) {
      saveChanges();
    });

    buttonCreate.onClick.listen((_) {
      createOrganizationHandler();
    });

    inputName.onInput.listen((_) {
      if(isNameEmpty()) {
        disableSaveButton();
      } else if(createNew || selectedOrganizationId != null) {
        enableSaveButton();
      }
    });

    inputFlag.onInput.listen((_) {
      if(selectedOrganizationId != null && !isNameEmpty()) {
        enableSaveButton();
      }
    });

    inputBillingtype.onInput.listen((_) {
      if(selectedOrganizationId != null && !isNameEmpty()) {
        enableSaveButton();
      }
    });

    buttonDelete.onClick.listen((_) {
      if (!createNew && selectedOrganizationId != null) {
        organizationController.remove(selectedOrganizationId).then((_) {
          notify.info('Organisation blev slettet.');

          currentContactList.clear();
          currentReceptionList.clear();
          bus.fire( new OrganizationRemovedEvent(selectedOrganizationId) );
          refreshList();
          clearContent();
          disableSaveButton();
          disableDeleteButton();
          selectedOrganizationId = null;
        }).catchError((error) {
          notify.error('Der skete en fejl i forbindelsen med sletningen.');
          log.error('Failed to delete organization "${selectedOrganizationId}", got "${error}"');
        });
      }
    });

    bus.on(WindowChanged).listen((WindowChanged event) {
      element.classes.toggle('hidden', event.window != viewName);
      if (event.data.containsKey('organization_id')) {
        activateOrganization(event.data['organization_id']);
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

  bool isNameEmpty() => inputName.value.trim() == "";

  void enableSaveButton() {
    buttonSave.disabled = false;
  }

  void disableSaveButton() {
    buttonSave.disabled = true;
  }

  void enableDeleteButton() {
    buttonDelete.disabled = false;
  }

  void disableDeleteButton() {
    buttonDelete.disabled = true;
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
    selectedOrganizationId = null;
    buttonSave.text = 'Opret';
    disableDeleteButton();
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
    List<ORModel.Organization> filteredList = organizations.where((ORModel.Organization org) =>
        org.fullName.toLowerCase().contains(searchText.toLowerCase())).toList();
    renderOrganizationList(filteredList);
  }

  void saveChanges() {
    if (selectedOrganizationId != null) {
      Map organization = {
        'id': selectedOrganizationId,
        'full_name': inputName.value,
        'billing_type': inputBillingtype.value,
        'flag': inputFlag.value
      };
      String newOrganization = JSON.encode(organization);
      organizationController.update(newOrganization).then((_) {
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
      organizationController.create(newOrganization).then((Map response) {
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
    organizationController.list().then((Iterable<ORModel.Organization> organizations) {

      int compareTo (ORModel.Organization org1, ORModel.Organization org2) => org1.fullName.compareTo(org2.fullName);

      List list = organizations.toList()..sort(compareTo);
      this.organizations = list;
      renderOrganizationList(list);
    }).catchError((error) {
      notify.error('Organisationerne blev ikke hentet da der er sket en fejl.');
      log.error('Tried to fetch organization list, got error: $error');
    });
  }

  void renderOrganizationList(List<ORModel.Organization> organizations) {
    uiList.children
      ..clear()
      ..addAll(organizations.map(makeOrganizationNode));
  }

  LIElement makeOrganizationNode(ORModel.Organization organization) {
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
    organizationController.get(organizationId).then((ORModel.Organization organization) {
      highlightOrganizationInList(organizationId);
      selectedOrganizationId = organizationId;
      createNew = false;
      buttonSave.text = 'Gem';
      disableSaveButton();
      enableDeleteButton();
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
    organizationController.receptions(organizationId).then((Iterable<ORModel.Reception> receptions) {

      int compareTo (ORModel.Reception r1, ORModel.Reception r2) => r1.fullName.compareTo(r2.fullName);

      List list = receptions.toList()..sort(compareTo);
      currentReceptionList = list;
      ulReceptionList.children
          ..clear()
          ..addAll(receptions.map(makeReceptionNode));
    });
  }

  LIElement makeReceptionNode(ORModel.Reception reception) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${reception.fullName}'
      ..onClick.listen((_) {
        Map data = {
          'organization_id': reception.organizationId,
          'reception_id': reception.ID
        };
        bus.fire(new WindowChanged(Menu.RECEPTION_WINDOW, data));
      });
    return li;
  }

  void updateContactList(int organizationId) {
    organizationController.contacts(organizationId).then((Iterable<ORModel.BaseContact> contacts) {
      int compareTo (ORModel.BaseContact c1, ORModel.BaseContact c2) => c1.fullName.compareTo(c2.fullName);

      List list = contacts.toList()..sort(compareTo);

      currentContactList = list;
      ulContactList.children
          ..clear()
          ..addAll(list.map(makeContactNode));
    }).catchError((error) {
      notify.error('Der skete en fejl i forbindelse med at hente kontakterne tilknyttet organisationen.');
      log.error('Tried to fetch the contactlist from an organization Error: $error');
    });
  }

  LIElement makeContactNode(ORModel.BaseContact contact) {
    LIElement li = new LIElement()
      ..classes.add('clickable')
      ..text = '${contact.fullName}'
      ..onClick.listen((_) {
        Map data = {
          'contact_id': contact.id
        };
        bus.fire(new WindowChanged(Menu.CONTACT_WINDOW, data));
      });
    return li;
  }
}
