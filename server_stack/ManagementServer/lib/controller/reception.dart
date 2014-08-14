library receptionController;

import 'dart:io';
import 'dart:convert';

import '../configuration.dart';
import '../database.dart';
import '../model.dart';
import '../view/reception.dart';
import 'package:openreception_framework/service.dart' as ORFService;
import 'package:openreception_framework/common.dart' as orf;
import 'package:openreception_framework/httpserver.dart' as orf_http;

const libraryName = 'receptionController';

class ReceptionController {
  final Database db;
  final Configuration config;

  ReceptionController(Database this.db, Configuration this.config);

  void getReception(HttpRequest request) {
    const String context = '${libraryName}.getReception';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');

    db.getReception(receptionId).then((Reception reception) {
      if (reception == null) {
        return orf_http.notFound(request, {});
      } else {
        return orf_http.writeAndClose(request, receptionAsJson(reception));
      }
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getReceptionList(HttpRequest request) {
    const String context = '${libraryName}.getReceptionList';

    db.getReceptionList().then((List<Reception> list) {
      return orf_http.writeAndClose(request, listReceptionAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getOrganizationReceptionList(HttpRequest request) {
    const String context = '${libraryName}.getOrganizationReceptionList';
    final int organizationId = orf_http.pathParameter(request.uri, 'organization');

    db.getOrganizationReceptionList(organizationId).then((List<Reception> list)
        {
      return orf_http.writeAndClose(request, listReceptionAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void createReception(HttpRequest request) {
    const String context = '${libraryName}.createReception';
    final int organizationId = orf_http.pathParameter(request.uri, 'organization');

    orf_http.extractContent(request).then(JSON.decode).then((Map data) =>
        db.createReception(organizationId, data['full_name'], data['attributes'], data['extradatauri'], data['enabled'], data['number']))
          .then((int id) => orf_http.writeAndClose(request, receptionIdAsJson(id))
          .then((_) {
              Map data = {'event' : 'receptionEventCreated', 'receptionEvent' : {'receptionId' : id}};
              ORFService.Notification.broadcast(data, config.notificationServer, config.token)
                .catchError((error) {
                  orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
                });
            }))
          .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updateReception(HttpRequest request) {
    const String context = '${libraryName}.updateReception';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');

    orf_http.extractContent(request).then(JSON.decode).then((Map data) =>
      db.updateReception(receptionId, data['organization_id'], data['full_name'],
      data['attributes'], data['extradatauri'], data['enabled'], data['number']))
        .then((_) => orf_http.writeAndClose(request, receptionIdAsJson(receptionId))
        .then((_) {
            Map data = {'event' : 'receptionEventUpdated', 'receptionEvent' : {'receptionId' : receptionId}};
            ORFService.Notification.broadcast(data, config.notificationServer, config.token)
              .catchError((error) {
                orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
              });
          }))
        .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void deleteReception(HttpRequest request) {
    const String context = '${libraryName}.deleteReception';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');

    db.deleteReception(receptionId)
      .then((_) => orf_http.writeAndClose(request, receptionIdAsJson(receptionId))
      .then((_) {
          Map data = {'event' : 'receptionEventDeleted', 'receptionEvent' : {'receptionId' : receptionId}};
          ORFService.Notification.broadcast(data, config.notificationServer, config.token)
            .catchError((error) {
              orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
            });
        }))
      .catchError((error, stack) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }
}
