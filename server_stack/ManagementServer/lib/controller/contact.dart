library contactController;

import 'dart:io';
import 'dart:convert';

import '../view/colleague.dart';
import '../configuration.dart';
import '../view/contact.dart';
import '../database.dart';
import '../model.dart';
import '../view/organization.dart';
import '../view/reception_contact_reduced_reception.dart';
import 'package:OpenReceptionFramework/service.dart' as orf_service;
import 'package:OpenReceptionFramework/common.dart' as orf;
import 'package:OpenReceptionFramework/httpserver.dart' as orf_http;

const libraryName = 'contactController';

class ContactController {
  Database db;
  Configuration config;

  ContactController(Database this.db, Configuration this.config);

  void createContact(HttpRequest request) {
    const context = '${libraryName}.createContact';

    orf_http.extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createContact(data['full_name'], data['contact_type'], data['enabled']))
    .then((int id) =>
        orf_http.writeAndClose(request, contactIdAsJson(id)).then((_) {
          Map data = {'event' : 'contactEventCreated', 'contactEvent' : {'contactId' : id}};
          orf_service.Notification.broadcast(data, config.notificationServer, config.token)
            .catchError((error) {
              orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
            });
        }))
    .catchError((error) {
      orf.logger.errorContext(error, context);
      orf_http.serverError(request, error.toString());
    });
  }

  void deleteContact(HttpRequest request) {
    const context = '${libraryName}.deleteContact';
    int contactId =  orf_http.pathParameter(request.uri, 'contact');

    db.deleteContact(contactId)
    .then((int rowsAffected) => orf_http.writeAndClose(request, JSON.encode({})))
    .then((_) {
      Map data = {'event' : 'contactEventDeleted', 'contactEvent' : {'contactId' : contactId}};
      orf_service.Notification.broadcast(data, config.notificationServer, config.token)
        .catchError((error) {
          orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
        });
    })
    .catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getAContactsOrganizationList(HttpRequest request) {
    const context = '${libraryName}.getAContactsOrganizationList';
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getAContactsOrganizationList(contactId).then((List<Organization> organizations) {
      orf_http.writeAndClose(request, listOrganizatonAsJson(organizations));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getColleagues(HttpRequest request) {
    const context = '${libraryName}.getColleagues';
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getContactColleagues(contactId).then((List<ReceptionColleague> receptions) {
      orf_http.writeAndClose(request, listReceptionColleaguesAsJson(receptions));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getContact(HttpRequest request) {
    const context = '${libraryName}.getContact';
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getContact(contactId).then((Contact contact) {
      if(contact == null) {
        request.response.statusCode = 404;
        return orf_http.writeAndClose(request, JSON.encode({}));
      } else {
        return orf_http.writeAndClose(request, contactAsJson(contact));
      }
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.writeAndClose(request, JSON.encode({}));
    });
  }

  void getContactList(HttpRequest request) {
    const context = '${libraryName}.getContactList';

    db.getContactList().then((List<Contact> list) {
      return orf_http.writeAndClose(request, listContactAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getContactTypeList(HttpRequest request) {
    const context = '${libraryName}.getContactTypeList';

    db.getContactTypeList().then((List<String> data) {
      orf_http.writeAndClose(request, contactTypesAsJson(data));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getAddressTypestList(HttpRequest request) {
    const context = '${libraryName}.getAddressTypestList';

    db.getAddressTypeList().then((List<String> data) {
      orf_http.writeAndClose(request, addressTypesAsJson(data));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getReceptionList(HttpRequest request) {
    const context = '${libraryName}.getReceptionList';
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getAContactsReceptionContactList(contactId).then((List<ReceptionContact_ReducedReception> data) {
      orf_http.writeAndClose(request, listReceptionContact_ReducedReceptionAsJson(data));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updateContact(HttpRequest request) {
    const context = '${libraryName}.updateContact';
    int contactId = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateContact(contactId, data['full_name'], data['contact_type'], data['enabled']))
    .then((int id) => orf_http.writeAndClose(request, contactIdAsJson(id)))
    .then((_) {
      Map data = {'event' : 'contactEventUpdated', 'contactEvent' : {'contactId' : contactId}};
      orf_service.Notification.broadcast(data, config.notificationServer, config.token)
        .catchError((error) {
          orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"', context);
        });
    })
    .catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }
}
