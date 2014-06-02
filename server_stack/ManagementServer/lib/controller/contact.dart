library contactController;

import 'dart:io';
import 'dart:convert';

import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/contact.dart';
import '../view/organization.dart';
import '../view/reception_contact_reduced_reception.dart';

class ContactController {
  Database db;

  ContactController(Database this.db);

  void createContact(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createContact(data['full_name'], data['contact_type'], data['enabled']))
    .then((int id) => writeAndCloseJson(request, contactIdAsJson(id)))
    .catchError((error) {
      logger.error(error);
      Internal_Error(request);
    });
  }

  void deleteContact(HttpRequest request) {
    db.deleteContact(pathParameter(request.uri, 'contact'))
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error('deleteContact url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getAContactsOrganizationList(HttpRequest request) {
    int contactId = pathParameter(request.uri, 'contact');
    db.getAContactsOrganizationList(contactId).then((List<Organization> organizations) {
      writeAndCloseJson(request, listOrganizatonAsJson(organizations));
    }).catchError((error) {
      logger.error('contractController.getAContactsOrganizationList url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getContact(HttpRequest request) {
    int contactId = pathParameter(request.uri, 'contact');

    db.getContact(contactId).then((Contact contact) {
      if(contact == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, contactAsJson(contact));
      }
    }).catchError((error) {
      String body = '$error';
      writeAndCloseJson(request, body);
    });
  }

  void getContactList(HttpRequest request) {
    db.getContactList().then((List<Contact> list) {
      return writeAndCloseJson(request, listContactAsJson(list));
    }).catchError((error) {
      logger.error('get contact list Error: "$error"');
      Internal_Error(request);
    });
  }

  void getContactTypeList(HttpRequest request) {
    db.getContactTypeList().then((List<String> data) {
      writeAndCloseJson(request, contactTypesAsJson(data));
    }).catchError((error) {
      logger.error('contractController.getContactTypeList url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getReceptionList(HttpRequest request) {
    int contactId = pathParameter(request.uri, 'contact');

    db.getAContactsReceptionContactList(contactId).then((List<ReceptionContact_ReducedReception> data) {
      writeAndCloseJson(request, listReceptionContact_ReducedReceptionAsJson(data));
    }).catchError((error) {
      logger.error('contractController.getReceptionList url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void updateContact(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateContact(pathParameter(request.uri, 'contact'), data['full_name'], data['contact_type'], data['enabled']))
    .then((int id) => writeAndCloseJson(request, contactIdAsJson(id)))
    .catchError((error) {
      logger.error('updateContact url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }
}