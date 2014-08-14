library organizationController;

import 'dart:io';
import 'dart:convert';

import '../configuration.dart';
import '../database.dart';
import '../model.dart';
import '../view/organization.dart';
import '../view/contact.dart';
import 'package:openreception_framework/service.dart' as ORFService;
import 'package:openreception_framework/common.dart' as orf;
import 'package:openreception_framework/httpserver.dart' as orf_http;

const libraryName = 'organizationController';

class OrganizationController {
  final Database db;
  final Configuration config;

  OrganizationController(Database this.db, Configuration this.config);

  void getOrganization(HttpRequest request) {
    const String context = '${libraryName}.getOrganization';
    final int organizationId = orf_http.pathParameter(request.uri, 'organization');

    db.getOrganization(organizationId).then((Organization organization) {
      if(organization == null) {
        request.response.statusCode = 404;
        return orf_http.allOk(request);
      } else {
        return orf_http.writeAndClose(request, organizationAsJson(organization));
      }
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getOrganizationList(HttpRequest request) {
    const String context = '${libraryName}.getOrganizationList';

    db.getOrganizationList().then((List<Organization> list) {
      return orf_http.writeAndClose(request, listOrganizatonAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void createOrganization(HttpRequest request) {
    const String context = '${libraryName}.createOrganization';

    orf_http.extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createOrganization(data['full_name'], data['bill_type'], data['flag']))
    .then((int id) => orf_http.writeAndClose(request, organizationIdAsJson(id)).then((_) {
      Map data = {'event' : 'organizationEventCreated', 'organizationEvent' : {'organizationId' : id}};
      ORFService.Notification.broadcast(data, config.notificationServer, config.token)
        .catchError((error) {
          orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
        });
    }))
    .catchError((error) {
      orf.logger.errorContext(error, context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updateOrganization(HttpRequest request) {
    const String context = '${libraryName}.updateOrganization';

    orf_http.extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateOrganization(orf_http.pathParameter(request.uri, 'organization'), data['full_name'], data['bill_type'], data['flag']))
    .then((int id) => orf_http.writeAndClose(request, organizationIdAsJson(id))
    .then((_) {
      Map data = {'event' : 'organizationEventupdated', 'organizationEvent' : {'organizationId' : id}};
      ORFService.Notification.broadcast(data, config.notificationServer, config.token)
        .catchError((error) {
          orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
        });
    }))
    .catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void deleteOrganization(HttpRequest request) {
    const String context = '${libraryName}.deleteOrganization';
    final int organizationId = orf_http.pathParameter(request.uri, 'organization');

    db.deleteOrganization(organizationId)
    .then((int id) => orf_http.writeAndClose(request, organizationIdAsJson(organizationId))
    .then((_) {
      Map data = {'event' : 'organizationEventDeleted', 'organizationEvent' : {'organizationId' : organizationId}};
      ORFService.Notification.broadcast(data, config.notificationServer, config.token)
        .catchError((error) {
          orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
        });
    }))
    .catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getOrganizationContactList(HttpRequest request) {
    const String context = '${libraryName}.getOrganizationContactList';

    db.getOrganizationContactList(orf_http.pathParameter(request.uri, 'organization')).then((List<Contact> contacts) {
      return orf_http.writeAndClose(request, listContactAsJson(contacts));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }
}
