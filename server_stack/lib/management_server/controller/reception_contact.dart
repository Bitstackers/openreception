library receptionContactController;

import 'dart:io';
import 'dart:convert';

import '../configuration.dart';
import '../database.dart';
import '../model.dart';
import '../router.dart';
import '../view/calendar_event.dart';
import '../view/complete_reception_contact.dart';
import '../view/endpoint.dart';
import '../view/distribution_list.dart';
import 'package:openreception_framework/common.dart' as orf;
import 'package:openreception_framework/event.dart' as orf_event;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/httpserver.dart' as orf_http;

const libraryName = 'receptionContactController';

class ReceptionContactController {
  final Database db;
  final Configuration config;

  ReceptionContactController(Database this.db, Configuration this.config);

  void getReceptionContact(HttpRequest request) {
    const String context = '${libraryName}.getReceptionContact';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getReceptionContact(receptionId, contactId).then((ReceptionContact contact) {
      if(contact == null) {
        return orf_http.notFound(request, {});
      } else {
        return orf_http.writeAndClose(request, receptionContactAsJson(contact));
      }
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getReceptionContactList(HttpRequest request) {
    const String context = '${libraryName}.getReceptionContactList';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');

    db.getReceptionContactList(receptionId).then((List<ReceptionContact> list) {
      return orf_http.writeAndClose(request, listReceptionContactAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void createReceptionContact(HttpRequest request) {
    const String context = '${libraryName}.createReceptionContact';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createReceptionContact(
        receptionId, contactId, data['wants_messages'],
        data['phonenumbers'], data['attributes'], data['enabled'])
    .then((_) {
        Notification.broadcastEvent(new orf_event.ReceptionContactChange (contactId, receptionId, orf_event.ReceptionContactState.CREATED))
        .catchError((error) {
            orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.serverToken} url: "${request.uri}" gave error "${error}"', context);
          });
      }))
    .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
    .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updateReceptionContact(HttpRequest request) {
    const String context = '${libraryName}.updateReceptionContact';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateReceptionContact(
        receptionId, contactId, data['wants_messages'],
        data['phonenumbers'], data['attributes'], data['enabled'])
    .then((_) {
      Notification.broadcastEvent(new orf_event.ReceptionContactChange (contactId, receptionId, orf_event.ReceptionContactState.UPDATED))
          .catchError((error) {
            orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.serverToken} url: "${request.uri}" gave error "${error}"', context);
          });
      }))
    .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
    .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void deleteReceptionContact(HttpRequest request) {
    const String context = '${libraryName}.deleteReceptionContact';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.deleteReceptionContact(receptionId, contactId)
    .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({}))
    .then((_) {
      Notification.broadcastEvent(new orf_event.ReceptionContactChange (contactId, receptionId, orf_event.ReceptionContactState.DELETED))
          .catchError((error) {
            orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.serverToken} url: "${request.uri}" gave error "${error}"', context);
          });
      }))
    .catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void createEndpoint(HttpRequest request) {
    const String context = '${libraryName}.createEndpoint';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.createEndpoint(receptionId, contactId, data['address'], data['address_type'], data['confidential'], data['enabled'], data['priority'], data['description'])
        .then((_) {
          Notification.broadcastEvent(new orf_event.EndpointChange (contactId, receptionId, orf_event.EndpointState.UPDATED, data['address'], data['address_type']))
              .catchError((error) {
                orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.serverToken} url: "${request.uri}" gave error "${error}"', context);
              });
          }))
      .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void getEndpoint(HttpRequest request) {
    const String context = '${libraryName}.getEndpoint';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');
    final String address = orf_http.pathParameterString(request.uri, 'endpoint');
    final String addressType = orf_http.pathParameterString(request.uri, 'type');

    db.getEndpoint(receptionId, contactId, address, addressType).then((Endpoint endpoint) {
      if(endpoint == null) {
        return orf_http.notFound(request, {});
      } else {
        return orf_http.writeAndClose(request, endpointAsJson(endpoint));
      }
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getEndpointList(HttpRequest request) {
    const String context = '${libraryName}.getEndpointList';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getEndpointList(receptionId, contactId).then((List<Endpoint> list) {
      return orf_http.writeAndClose(request, endpointListAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updateEndpoint(HttpRequest request) {
    const String context = '${libraryName}.updateEndpoint';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');
    final String address = orf_http.pathParameterString(request.uri, 'endpoint');
    final String addressType = orf_http.pathParameterString(request.uri, 'type');

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
          Notification.broadcastEvent(new orf_event.EndpointChange (newreceptionId, newContactId, orf_event.EndpointState.UPDATED, newAddress, newAddressType))
            .catchError((error) {
              orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.serverToken} url: "${request.uri}" gave error "${error}"', context);
            });
        })
      .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void deleteEndpoint(HttpRequest request) {
    const String context = '${libraryName}.deleteEndpoint';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');
    final String address = orf_http.pathParameterString(request.uri, 'endpoint');
    final String addressType = orf_http.pathParameterString(request.uri, 'type');

    db.deleteEndpoint(receptionId, contactId, address, addressType)
      .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({}))
      .then((_) {
          Notification.broadcastEvent(new orf_event.EndpointChange (receptionId, contactId, orf_event.EndpointState.DELETED, address, addressType))
            .catchError((error) {
              orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.serverToken} url: "${request.uri}" gave error "${error}"', context);
            });
        }))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void getDistributionList(HttpRequest request) {
    const String context  = '${libraryName}.getDistributionList';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId   = orf_http.pathParameter(request.uri, 'contact');

    db.getDistributionList(receptionId, contactId)
      .then((DistributionList distributionList) => orf_http.writeAndClose(request, distributionListAsJson(distributionList)))
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void createDistributionListEntry(HttpRequest request) {
    const String context  = '${libraryName}.createDistributionListEntry';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId   = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.createDistributionListEntry(
          receptionId, contactId, data['role'],
          data['reception_id'], data['contact_id']))
      .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void deleteDistributionListEntry(HttpRequest request) {
    const String context  = '${libraryName}.deleteDistributionListEntry';
//    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
//    final int contactId   = orf_http.pathParameter(request.uri, 'contact');
    final int entryId   = orf_http.pathParameter(request.uri, 'distributionlist');

    db.deleteDistributionListEntry(entryId)
      .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error) {
        orf.logger.errorContext('Error: "$error"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  /**
   * Temporary interface, only meant to be here while migrating.
   */
  void moveContact(HttpRequest request) {
    const String context = '${libraryName}.moveContact';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');
    final int newContactId = orf_http.pathParameter(request.uri, 'newContactId');

    db.moveReceptionContact(receptionId, contactId, newContactId)
      .then((_) => orf_http.writeAndClose(request, JSON.encode({})))
      .catchError((error, stack) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void getCalendarEvents(HttpRequest request) {
    const String context = '${libraryName}.getCalendarEvents';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getReceptionContactCalendarEvents(receptionId, contactId)
      .then((List<Event> events) => orf_http.allOk(request, listEventsAsJson(events)))
      .catchError((error, stack) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
        orf_http.serverError(request, error.toString());
    });
  }

  void createCalendarEvent(HttpRequest request) {
    const String context = '${libraryName}.createCalendarEvent';
    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) {
        DateTime start = new DateTime.fromMillisecondsSinceEpoch(data['start']*1000);
        DateTime stop = new DateTime.fromMillisecondsSinceEpoch(data['stop']*1000);
        String message = data['content'];
        return db.createReceptionContactCalendarEvent(receptionId, contactId, message, start, stop);
      }).then((int id) {
      return orf_http.writeAndClose(request, '{"id": ${id}}');
    }).catchError((error, stack) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void deleteCalendarEvent(HttpRequest request) {
    const String context = '${libraryName}.deleteCalendarEvent';
//    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
//    final int contactId = orf_http.pathParameter(request.uri, 'contact');
    final int eventId = orf_http.pathParameter(request.uri, 'calendar');

    db.deleteCalendarEvent(eventId).then((int rowsAffted) {
      return orf_http.allOk(request);
    }).catchError((error, stack) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updateCalendarEvent(HttpRequest request) {
    const String context = '${libraryName}.updateCalendarEvent';
//    final int receptionId = orf_http.pathParameter(request.uri, 'reception');
//    final int contactId = orf_http.pathParameter(request.uri, 'contact');
    final int eventId = orf_http.pathParameter(request.uri, 'calendar');

    orf_http.extractContent(request)
    .then(JSON.decode)
    .then((Map data) {
      DateTime start = new DateTime.fromMillisecondsSinceEpoch(data['start']*1000);
      DateTime stop = new DateTime.fromMillisecondsSinceEpoch(data['stop']*1000);
      return db.updateCalendarEvent(eventId, data['content'], start, stop);
    })
    .then((_) => orf_http.allOk(request))
    .catchError((error, stack) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}" ${stack}', context);
      orf_http.serverError(request, error.toString());
    });
  }
}
