library contactController;

import 'dart:io';
import 'dart:convert';

import '../view/colleague.dart';
import '../configuration.dart';
import '../view/contact.dart';
import '../database.dart';
import '../model.dart';
import '../router.dart';
import '../view/organization.dart';
import '../view/reception_contact_reduced_reception.dart';
import 'package:openreception_framework/common.dart' as orf;
import 'package:openreception_framework/httpserver.dart' as orf_http;

const libraryName = 'contactController';

class ContactController {
  final Database db;
  final Configuration config;

  ContactController(Database this.db, Configuration this.config);

  void createContact(HttpRequest request) {
    const String context = '${libraryName}.createContact';

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.createContact(data['full_name'], data['contact_type'], data['enabled']))
      .then((int id) =>
          orf_http.writeAndClose(request, contactIdAsJson(id)).then((_) {
            Map data = {'event' : 'contactEventCreated', 'contactEvent' : {'contactId' : id}};
            Notification.broadcast(data)
              .catchError((error) {
                orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.serverToken} url: "${request.uri}" gave error "${error}"', context);
              });
          }))
      .catchError((error) {
        orf.logger.errorContext(error, context);
        orf_http.serverError(request, error.toString());
      });
  }

  void deleteContact(HttpRequest request) {
    const String context = '${libraryName}.deleteContact';
    final int contactId =  orf_http.pathParameter(request.uri, 'contact');

    db.deleteContact(contactId)
      .then((_) => orf_http.allOk(request))
      .then((_) {
        Map data = {'event' : 'contactEventDeleted', 'contactEvent' : {'contactId' : contactId}};
        return Notification.broadcast(data)
          .catchError((error) {
            orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.serverToken} url: "${request.uri}" gave error "${error}"', context);
          });
      })
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
      });
  }

  void getAContactsOrganizationList(HttpRequest request) {
    const String context = '${libraryName}.getAContactsOrganizationList';
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getAContactsOrganizationList(contactId).then((List<Organization> organizations) {
      orf_http.writeAndClose(request, listOrganizatonAsJson(organizations));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getColleagues(HttpRequest request) {
    const String context = '${libraryName}.getColleagues';
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getContactColleagues(contactId).then((List<ReceptionColleague> receptions) {
      orf_http.writeAndClose(request, listReceptionColleaguesAsJson(receptions));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getContact(HttpRequest request) {
    const String context = '${libraryName}.getContact';
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getContact(contactId).then((Contact contact) {
      if(contact == null) {
        return orf_http.notFound(request, {});
      } else {
        return orf_http.writeAndClose(request, contactAsJson(contact));
      }
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.allOk(request);
    });
  }

  void getContactList(HttpRequest request) {
    const String context = '${libraryName}.getContactList';

    db.getContactList().then((List<Contact> list) {
      return orf_http.writeAndClose(request, listContactAsJson(list));
    }).catchError((error) {
      orf.logger.errorContext('Error: "$error"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getContactTypeList(HttpRequest request) {
    const String context = '${libraryName}.getContactTypeList';

    db.getContactTypeList().then((List<String> data) {
      orf_http.writeAndClose(request, contactTypesAsJson(data));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getAddressTypestList(HttpRequest request) {
    const String context = '${libraryName}.getAddressTypestList';

    db.getAddressTypeList().then((List<String> data) {
      orf_http.writeAndClose(request, addressTypesAsJson(data));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getReceptionList(HttpRequest request) {
    const String context = '${libraryName}.getReceptionList';
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getAContactsReceptionContactList(contactId).then((List<ReceptionContact_ReducedReception> data) {
      orf_http.writeAndClose(request, listReceptionContact_ReducedReceptionAsJson(data));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void updateContact(HttpRequest request) {
    const String context = '${libraryName}.updateContact';
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    orf_http.extractContent(request)
      .then(JSON.decode)
      .then((Map data) => db.updateContact(contactId, data['full_name'], data['contact_type'], data['enabled']))
      .then((int id) => orf_http.writeAndClose(request, contactIdAsJson(id)))
      .then((_) {
        Map data = {'event' : 'contactEventUpdated', 'contactEvent' : {'contactId' : contactId}};
        Notification.broadcast(data)
          .catchError((error) {
            orf.logger.errorContext('Sending notification. NotificationServer: ${config.notificationServer} token: ${config.serverToken} url: "${request.uri}" gave error "${error}"', context);
          });
      })
      .catchError((error) {
        orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
        orf_http.serverError(request, error.toString());
      });
  }
}
