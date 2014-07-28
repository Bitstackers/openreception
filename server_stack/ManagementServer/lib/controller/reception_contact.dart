library receptionContactController;

import 'dart:io';
import 'dart:convert';

import '../configuration.dart';
import '../database.dart';
import '../model.dart';
import '../view/complete_reception_contact.dart';
import '../view/endpoint.dart';
import '../view/distribution_list.dart';
import 'package:OpenReceptionFramework/service.dart' as ORFService;
import 'package:OpenReceptionFramework/common.dart' as orf;
import 'package:OpenReceptionFramework/httpserver.dart' as orf_http;

const libraryName = 'receptionContactController';

class ReceptionContactController {
  Database db;
  Configuration config;

  ReceptionContactController(Database this.db, Configuration this.config);

  void getReceptionContact(HttpRequest request) {
    const context = '${libraryName}.getReceptionContact';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getReceptionContact(receptionId, contactId).then((ReceptionContact contact) {
      if(contact == null) {
        request.response.statusCode = 404;
        return orf_http.writeAndClose(request, JSON.encode({}));
      } else {
        return orf_http.writeAndClose(request, receptionContactAsJson(contact));
      }
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getReceptionContactList(HttpRequest request) {
    const context = '${libraryName}.getReceptionContactList';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');

    db.getReceptionContactList(receptionId).then((List<ReceptionContact> list) {
      return orf_http.writeAndClose(request, listReceptionContactAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void createReceptionContact(HttpRequest request) {
    const context = '${libraryName}.createReceptionContact';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createReceptionContact(
        receptionId, contactId, data['wants_messages'],
        data['phonenumbers'], data['attributes'], data['enabled'])
    .then((_) {
        Map data = {'event' : 'receptionContactEventCreated', 'receptionContactEvent' : {'receptionId': receptionId, 'contactId': contactId}};
        ORFService.Notification.broadcast(data, config.notificationServer, config.token)
          .catchError((error) {
            orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
          });
      }))
    .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
    .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updateReceptionContact(HttpRequest request) {
    const context = '${libraryName}.updateReceptionContact';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateReceptionContact(
        receptionId, contactId, data['wants_messages'],
        data['phonenumbers'], data['attributes'], data['enabled'])
    .then((_) {
        Map data = {'event' : 'receptionContactEventUpdated', 'receptionContactEvent' : {'receptionId': receptionId, 'contactId': contactId}};
        ORFService.Notification.broadcast(data, config.notificationServer, config.token)
          .catchError((error) {
            orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
          });
      }))
    .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
    .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void deleteReceptionContact(HttpRequest request) {
    const context = '${libraryName}.deleteReceptionContact';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.deleteReceptionContact(receptionId, contactId)
    .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({}))
    .then((_) {
        Map data = {'event' : 'receptionContactEventDeleted', 'receptionContactEvent' : {'receptionId': receptionId, 'contactId': contactId}};
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

  void createEndpoint(HttpRequest request) {
    const context = '${libraryName}.createEndpoint';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.createEndpoint(receptionId, contactId, data['address'], data['address_type'], data['confidential'], data['enabled'], data['priority'], data['description'])
        .then((_) {
            Map event = {'event' : 'endpointEventCreated', 'endpointEvent' : {'receptionId': receptionId, 'contactId': contactId, 'address': data['address'], 'address_type': data['address_type']}};
            ORFService.Notification.broadcast(event, config.notificationServer, config.token)
              .catchError((error) {
                orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
              });
          }))
      .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
      });
  }

  void getEndpoint(HttpRequest request) {
    const context = '${libraryName}.getEndpoint';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');
    String address = orf_http.pathParameterString(request.uri, 'endpoint');
    String addressType = orf_http.pathParameterString(request.uri, 'type');

    db.getEndpoint(receptionId, contactId, address, addressType).then((Endpoint endpoint) {
      if(endpoint == null) {
        request.response.statusCode = 404;
        return orf_http.writeAndClose(request, JSON.encode({}));
      } else {
        return orf_http.writeAndClose(request, endpointAsJson(endpoint));
      }
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getEndpointList(HttpRequest request) {
    const context = '${libraryName}.getEndpointList';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getEndpointList(receptionId, contactId).then((List<Endpoint> list) {
      return orf_http.writeAndClose(request, endpointListAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updateEndpoint(HttpRequest request) {
    const context = '${libraryName}.updateEndpoint';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');
    String address = orf_http.pathParameterString(request.uri, 'endpoint');
    String addressType = orf_http.pathParameterString(request.uri, 'type');

    int newreceptionId, newContactId;
    String newAddress, newAddressType;

    orf_http.extractContent(request)
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
            data['priority'],
            data['description']);
      })
      .then((_) {
          Map data = {'event' : 'endpointEventUpdated', 'endpointEvent' : {'reception_id': newreceptionId, 'contact_id': newContactId, 'address': newAddress, 'address_type': newAddressType}};
          ORFService.Notification.broadcast(data, config.notificationServer, config.token)
            .catchError((error) {
              orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
            });
        })
      .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void deleteEndpoint(HttpRequest request) {
    const context = '${libraryName}.deleteEndpoint';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');
    String address = orf_http.pathParameterString(request.uri, 'endpoint');
    String addressType = orf_http.pathParameterString(request.uri, 'type');

    db.deleteEndpoint(receptionId, contactId, address, addressType)
    .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({}))
    .then((_) {
        Map data = {'event' : 'endpointEventDeleted', 'endpointEvent' : {'receptionId': receptionId, 'contactId': contactId, 'address': address, 'address_type': addressType}};
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

  void getDistributionList(HttpRequest request) {
    const context = '${libraryName}.getDistributionList';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getDistributionList(receptionId, contactId)
      .then((DistributionList distributionList) => orf_http.writeAndClose(request, distributionListAsJson(distributionList)))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
    });

  }

  void updateDistributionList(HttpRequest request) {
    const context = '${libraryName}.updateDistributionList';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updateDistributionList(receptionId, contactId, data))
      .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error, stack) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void moveContact(HttpRequest request) {
    const context = '${libraryName}.moveContact';
    int receptionId = orf_http.pathParameter(request.uri, 'reception');
    int contactId = orf_http.pathParameter(request.uri, 'contact');
    int newContactId = orf_http.pathParameter(request.uri, 'newContactId');

    db.moveReceptionContact(receptionId, contactId, newContactId)
      .then((_) => db.getDistributionList(receptionId, newContactId))
      .then((DistributionList list) {
      bool madeChanges = false;
      for(ReceptionContact rc in list.to) {
        if(rc.receptionId == receptionId && rc.contactId == contactId) {
          rc.contactId = newContactId;
          madeChanges = true;
        }
      }
      for(ReceptionContact rc in list.cc) {
        if(rc.receptionId == receptionId && rc.contactId == contactId) {
          rc.contactId = newContactId;
          madeChanges = true;
        }
      }
      for(ReceptionContact rc in list.bcc) {
        if(rc.receptionId == receptionId && rc.contactId == contactId) {
          rc.contactId = newContactId;
          madeChanges = true;
        }
      }
      if(madeChanges) {
        return db.updateDistributionList(receptionId, newContactId, JSON.decode(distributionListAsJson(list)));
      }
    })
      .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error, stack) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
        orf_http.serverError(request, error.toString());
    });
  }
}
