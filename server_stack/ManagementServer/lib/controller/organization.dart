library organizationController;

import 'dart:io';
import 'dart:convert';

import '../configuration.dart';
import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/organization.dart';
import '../view/contact.dart';
import 'package:OpenReceptionFramework/service.dart' as ORFService;

class OrganizationController {
  Database db;
  Configuration config;

  OrganizationController(Database this.db, Configuration this.config);

  void getOrganization(HttpRequest request) {
    int organizationId = intPathParameter(request.uri, 'organization');

    db.getOrganization(organizationId).then((Organization organization) {
      if(organization == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, organizationAsJson(organization));
      }
    }).catchError((error) {
      logger.error('get organization Error: "$error"');
      String body = JSON.encode({'error': '$error'});
      Internal_Error(request, body);
    });
  }

  void getOrganizationList(HttpRequest request) {
    db.getOrganizationList().then((List<Organization> list) {
      return writeAndCloseJson(request, listOrganizatonAsJson(list));
    }).catchError((error) {
      logger.error('get organization list Error: "$error"');
      Internal_Error(request);
    });
  }

  void createOrganization(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createOrganization(data['full_name'], data['bill_type'], data['flag']))
    .then((int id) => writeAndCloseJson(request, organizationIdAsJson(id)).then((_) {
      Map data = {'event' : 'organizationEventCreated', 'organizationEvent' : {'organizationId' : id}};
      ORFService.Notification.broadcast(data, config.notificationServer, config.token)
        .catchError((error) {
          logger.error('createOrganization Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
        });
    }))
    .catchError((error) {
      logger.error(error);
      Internal_Error(request);
    });
  }

  void updateOrganization(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateOrganization(intPathParameter(request.uri, 'organization'), data['full_name'], data['bill_type'], data['flag']))
    .then((int id) => writeAndCloseJson(request, organizationIdAsJson(id))
    .then((_) {
      Map data = {'event' : 'organizationEventupdated', 'organizationEvent' : {'organizationId' : id}};
      ORFService.Notification.broadcast(data, config.notificationServer, config.token)
        .catchError((error) {
          logger.error('updateOrganization Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
        });
    }))
    .catchError((error) {
      logger.error('updateOrganization url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void deleteOrganization(HttpRequest request) {
    var organizationId = intPathParameter(request.uri, 'organization');
    db.deleteOrganization(organizationId)
    .then((int id) => writeAndCloseJson(request, organizationIdAsJson(organizationId))
    .then((_) {
      Map data = {'event' : 'organizationEventDeleted', 'organizationEvent' : {'organizationId' : organizationId}};
      ORFService.Notification.broadcast(data, config.notificationServer, config.token)
        .catchError((error) {
          logger.error('deleteOrganization Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
        });
    }))
    .catchError((error) {
      logger.error('deleteOrganization url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getOrganizationContactList(HttpRequest request) {
    db.getOrganizationContactList(intPathParameter(request.uri, 'organization')).then((List<Contact> contacts) {
      return writeAndCloseJson(request, listContactAsJson(contacts));
    }).catchError((error) {
      logger.error('get contact list Error: "$error"');
      Internal_Error(request);
    });
  }
}