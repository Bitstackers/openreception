library receptionContactController;

import 'dart:io';
import 'dart:convert';

import '../configuration.dart';
import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/complete_reception_contact.dart';
import 'package:OpenReceptionFramework/service.dart' as ORFService;

class ReceptionContactController {
  Database db;
  Configuration config;

  ReceptionContactController(Database this.db, Configuration this.config);

  void getReceptionContact(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');
    int contactId = intPathParameter(request.uri, 'contact');

    db.getReceptionContact(receptionId, contactId).then((CompleteReceptionContact contact) {
      if(contact == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, receptionContactAsJson(contact));
      }
    }).catchError((error) {
      logger.error('get reception contact Error: "$error"');
      Internal_Error(request);
    });
  }

  void getReceptionContactList(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');

    db.getReceptionContactList(receptionId).then((List<CompleteReceptionContact> list) {
      return writeAndCloseJson(request, listReceptionContactAsJson(list));
    }).catchError((error) {
      logger.error('get reception contact list Error: "$error"');
      Internal_Error(request);
    });
  }

  void createReceptionContact(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');
    int contactId = intPathParameter(request.uri, 'contact');

    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createReceptionContact(
        receptionId, contactId, data['wants_messages'],
        data['phonenumbers'], data['attributes'], data['enabled'])
    .then((_) {
        Map data = {'event' : 'receptionContactEventCreated', 'receptionContactEvent' : {'receptionId': receptionId, 'contactId': contactId}};
        ORFService.Notification.broadcast(data, config.notificationServer, config.token)
          .catchError((error) {
            logger.error('createReceptionContact Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
          });
      }))
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error(error);
      Internal_Error(request);
    });
  }

  void updateReceptionContact(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');
    int contactId = intPathParameter(request.uri, 'contact');

    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateReceptionContact(
        receptionId, contactId, data['wants_messages'],
        data['phonenumbers'], data['attributes'], data['enabled'])
    .then((_) {
        Map data = {'event' : 'receptionContactEventUpdated', 'receptionContactEvent' : {'receptionId': receptionId, 'contactId': contactId}};
        ORFService.Notification.broadcast(data, config.notificationServer, config.token)
          .catchError((error) {
            logger.error('updateReceptionContact Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
          });
      }))
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error('updateReception url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void deleteReceptionContact(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');
    int contactId = intPathParameter(request.uri, 'contact');

    db.deleteReceptionContact(receptionId, contactId)
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({}))
    .then((_) {
        Map data = {'event' : 'receptionContactEventDeleted', 'receptionContactEvent' : {'receptionId': receptionId, 'contactId': contactId}};
        ORFService.Notification.broadcast(data, config.notificationServer, config.token)
          .catchError((error) {
            logger.error('deleteReceptionContact Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
          });
      }))
    .catchError((error) {
      logger.error('updateReception url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }
}