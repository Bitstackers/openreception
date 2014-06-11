library organizationController;

import 'dart:io';
import 'dart:convert';

import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/organization.dart';
import '../view/contact.dart';

class OrganizationController {
  Database db;

  OrganizationController(Database this.db);

  void getOrganization(HttpRequest request) {
    int organizationId = pathParameter(request.uri, 'organization');

    db.getOrganization(organizationId).then((Organization organization) {
      if(organization == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, organizationAsJson(organization));
      }
    }).catchError((error) {
      String body = '$error';
      writeAndCloseJson(request, body);
    });
  }

  void getOrganizationList(HttpRequest request) {
    db.getOrganizationList().then((List<Organization> list) {
      return writeAndCloseJson(request, listOrganizatonAsJson(list));
    }).catchError((error) {
      logger.error('get reception list Error: "$error"');
      Internal_Error(request);
    });
  }

  void createOrganization(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createOrganization(data['full_name'], data['bill_type'], data['flag']))
    .then((int id) => writeAndCloseJson(request, organizationIdAsJson(id)))
    .catchError((error) {
      logger.error(error);
      Internal_Error(request);
    });
  }

  void updateOrganization(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateOrganization(pathParameter(request.uri, 'organization'), data['full_name'], data['bill_type'], data['flag']))
    .then((int id) => writeAndCloseJson(request, organizationIdAsJson(id)))
    .catchError((error) {
      logger.error('updateOrganization url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void deleteOrganization(HttpRequest request) {
    db.deleteOrganization(pathParameter(request.uri, 'organization'))
    .then((int id) => writeAndCloseJson(request, organizationIdAsJson(id)))
    .catchError((error) {
      logger.error('deleteOrganization url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getOrganizationContactList(HttpRequest request) {
    db.getOrganizationContactList(pathParameter(request.uri, 'organization')).then((List<Contact> contacts) {
      return writeAndCloseJson(request, listContactAsJson(contacts));
    }).catchError((error) {
      logger.error('get contact list Error: "$error"');
      Internal_Error(request);
    });
  }
}