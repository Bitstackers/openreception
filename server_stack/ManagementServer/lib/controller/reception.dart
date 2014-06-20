library receptionController;

import 'dart:io';
import 'dart:convert';

import 'package:libdialplan/libdialplan.dart';

import '../configuration.dart';
import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/dialplan.dart';
import '../view/reception.dart';
import 'package:OpenReceptionFramework/service.dart' as ORFService;

class ReceptionController {
  Database db;
  Configuration config;

  ReceptionController(Database this.db, Configuration this.config);

  void getReception(HttpRequest request) {
    int organizationId = intPathParameter(request.uri, 'organization');
    int receptionId = intPathParameter(request.uri, 'reception');

    db.getReception(organizationId, receptionId).then((Reception reception) {
      if (reception == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, receptionAsJson(reception));
      }
    }).catchError((error) {
      logger.error('get reception Error: "$error"');
      Internal_Error(request);
    });
  }

  void getReceptionList(HttpRequest request) {
    db.getReceptionList().then((List<Reception> list) {
      return writeAndCloseJson(request, listReceptionAsJson(list));
    }).catchError((error) {
      logger.error('get reception list Error: "$error"');
      Internal_Error(request);
    });
  }

  void getOrganizationReceptionList(HttpRequest request) {
    int organizationId = intPathParameter(request.uri, 'organization');

    db.getOrganizationReceptionList(organizationId).then((List<Reception> list)
        {
      return writeAndCloseJson(request, listReceptionAsJson(list));
    }).catchError((error) {
      logger.error('get reception list Error: "$error"');
      Internal_Error(request);
    });
  }

  void createReception(HttpRequest request) {
    int organizationId = intPathParameter(request.uri, 'organization');

    extractContent(request).then(JSON.decode).then((Map data) =>
        db.createReception(organizationId, data['full_name'], data['attributes'], data['extradatauri'], data['enabled'], data['number']))
          .then((int id) => writeAndCloseJson(request, receptionIdAsJson(id))
          .then((_) {
              Map data = {'event' : 'receptionEventCreated', 'receptionEvent' : {'receptionId' : id}};
              ORFService.Notification.broadcast(data, config.notificationServer, config.token)
                .catchError((error) {
                  logger.error('createReception Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
                });
            }))
          .catchError((error) {
      logger.error(error);
      Internal_Error(request);
    });
  }

  void updateReception(HttpRequest request) {
    int organizationId = intPathParameter(request.uri, 'organization');
    int receptionId = intPathParameter(request.uri, 'reception');

    extractContent(request).then(JSON.decode).then((Map data) =>
      db.updateReception(organizationId, receptionId, data['full_name'],
      data['attributes'], data['extradatauri'], data['enabled'], data['number']))
        .then((_) => writeAndCloseJson(request, receptionIdAsJson(receptionId))
        .then((_) {
            Map data = {'event' : 'receptionEventUpdated', 'receptionEvent' : {'receptionId' : receptionId}};
            ORFService.Notification.broadcast(data, config.notificationServer, config.token)
              .catchError((error) {
                logger.error('updateReception Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
              });
          }))
        .catchError((error) {
          logger.error('updateReception url: "${request.uri}" gave error "${error}"');
          Internal_Error(request);
    });
  }

  void deleteReception(HttpRequest request) {
    int organizationId = intPathParameter(request.uri, 'organization');
    int receptionId = intPathParameter(request.uri, 'reception');

    db.deleteReception(organizationId, receptionId)
      .then((_) => writeAndCloseJson(request, receptionIdAsJson(receptionId))
      .then((_) {
          Map data = {'event' : 'receptionEventDeleted', 'receptionEvent' : {'receptionId' : receptionId}};
          ORFService.Notification.broadcast(data, config.notificationServer, config.token)
            .catchError((error) {
              logger.error('deleteReception Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
            });
        }))
      .catchError((error, stack) {
        logger.error('deleteReception url: "${request.uri}" gave error "${error}" ${stack}');
        Internal_Error(request);
    });
  }

  void getDialplan(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');

    db.getDialplan(receptionId)
      .then((Dialplan dialplan) => writeAndCloseJson(request, dialplanAsJson(dialplan)))
      .catchError((error) {
        logger.error('getDialplan url: "${request.uri}" gave error "${error}"');
        Internal_Error(request);
    });
  }

  void updateDialplan(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');

    extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updateDialplan(receptionId, data))
      .then((_) => writeAndCloseJson(request, JSON.encode({})))
      .catchError((error, stack) {
        logger.error('updateDialplan url: "${request.uri}" gave error "${error}" ${stack}');
        Internal_Error(request);
    });
  }
}
