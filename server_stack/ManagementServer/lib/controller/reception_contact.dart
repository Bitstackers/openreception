library receptionContactController;

import 'dart:io';
import 'dart:convert';

import '../configuration.dart';
import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/complete_reception_contact.dart';
import '../view/endpoint.dart';
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
    .then((_) => writeAndCloseJson(request, JSON.encode({})))
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

  void createEndpoint(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');
    int contactId = intPathParameter(request.uri, 'contact');

    extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.createEndpoint(receptionId, contactId, data['address'], data['address_type'], data['confidential'], data['enabled'], data['priority'])
        .then((_) {
            Map event = {'event' : 'endpointEventCreated', 'endpointEvent' : {'receptionId': receptionId, 'contactId': contactId, 'address': data['address'], 'address_type': data['address_type']}};
            ORFService.Notification.broadcast(event, config.notificationServer, config.token)
              .catchError((error) {
                logger.error('createEndpoint Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
              });
          }))
      .then((_) => writeAndCloseJson(request, JSON.encode({})))
      .catchError((error) {
        logger.error(error);
        Internal_Error(request);
      });
  }

  void getEndpoint(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');
    int contactId = intPathParameter(request.uri, 'contact');
    String address = PathParameter(request.uri, 'endpoint');
    String addressType = PathParameter(request.uri, 'type');

    db.getEndpoint(receptionId, contactId, address, addressType).then((Endpoint endpoint) {
      if(endpoint == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, endpointAsJson(endpoint));
      }
    }).catchError((error) {
      logger.error('getEndpoint Error: "$error"');
      Internal_Error(request);
    });
  }

  void getEndpointList(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');
    int contactId = intPathParameter(request.uri, 'contact');

    db.getEndpointList(receptionId, contactId).then((List<Endpoint> list) {
      return writeAndCloseJson(request, endpointListAsJson(list));
    }).catchError((error) {
      logger.error('getEndpointList Error: "$error"');
      Internal_Error(request);
    });
  }

  void updateEndpoint(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');
    int contactId = intPathParameter(request.uri, 'contact');
    String address = PathParameter(request.uri, 'endpoint');
    String addressType = PathParameter(request.uri, 'type');

    int newreceptionId, newContactId;
    String newAddress, newAddressType;

    extractContent(request)
    .then(JSON.decode)
    .then((Map data) {
      newreceptionId = data['reception_id'];
      newContactId = data['contact_id'];
      newAddress = data['address'];
      newAddressType = data['address_type'];

      return db.updateEndpoint(
          receptionId,
          contactId,
          address,
          addressType,
          data['reception_id'],
          data['contact_id'],
          data['address'],
          data['address_type'],
          data['confidential'],
          data['enabled'],
          data['priority']);
    })
    .then((_) {
        Map data = {'event' : 'endpointEventUpdated', 'endpointEvent' : {'reception_id': newreceptionId, 'contact_id': newContactId, 'address': newAddress, 'address_type': newAddressType}};
        ORFService.Notification.broadcast(data, config.notificationServer, config.token)
          .catchError((error) {
            logger.error('updateEndpoint Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
          });
      })
    .then((_) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error('updateEndpoint url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void deleteEndpoint(HttpRequest request) {
    int receptionId = intPathParameter(request.uri, 'reception');
    int contactId = intPathParameter(request.uri, 'contact');
    String address = PathParameter(request.uri, 'endpoint');
    String addressType = PathParameter(request.uri, 'type');

    db.deleteEndpoint(receptionId, contactId, address, addressType)
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({}))
    .then((_) {
        Map data = {'event' : 'endpointEventDeleted', 'endpointEvent' : {'receptionId': receptionId, 'contactId': contactId, 'address': address, 'address_type': addressType}};
        ORFService.Notification.broadcast(data, config.notificationServer, config.token)
          .catchError((error) {
            logger.error('deleteEndpoint Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
          });
      }))
    .catchError((error) {
      logger.error('deleteEndpoint url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }
}