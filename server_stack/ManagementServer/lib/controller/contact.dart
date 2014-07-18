library contactController;

import 'dart:io';
import 'dart:convert';

import '../view/colleague.dart';
import '../configuration.dart';
import '../view/contact.dart';
import '../database.dart';
import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../model.dart';
import '../view/organization.dart';
import '../view/reception_contact_reduced_reception.dart';
import 'package:OpenReceptionFramework/service.dart' as ORFService;

class ContactController {
  Database db;
  Configuration config;

  ContactController(Database this.db, Configuration this.config);

  void createContact(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.createContact(data['full_name'], data['contact_type'], data['enabled']))
    .then((int id) =>
        writeAndCloseJson(request, contactIdAsJson(id)).then((_) {
          Map data = {'event' : 'contactEventCreated', 'contactEvent' : {'contactId' : id}};
          ORFService.Notification.broadcast(data, config.notificationServer, config.token)
            .catchError((error) {
              logger.error('createContact Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
            });
        }))
    .catchError((error) {
      logger.error(error);
      Internal_Error(request);
    });
  }

  void deleteContact(HttpRequest request) {
    int contactId = intPathParameter(request.uri, 'contact');
    db.deleteContact(contactId)
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .then((_) {
      Map data = {'event' : 'contactEventDeleted', 'contactEvent' : {'contactId' : contactId}};
      ORFService.Notification.broadcast(data, config.notificationServer, config.token)
        .catchError((error) {
          logger.error('deleteContact Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
        });
    })
    .catchError((error) {
      logger.error('deleteContact url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getAContactsOrganizationList(HttpRequest request) {
    int contactId = intPathParameter(request.uri, 'contact');
    db.getAContactsOrganizationList(contactId).then((List<Organization> organizations) {
      writeAndCloseJson(request, listOrganizatonAsJson(organizations));
    }).catchError((error) {
      logger.error('contractController.getAContactsOrganizationList url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getColleagues(HttpRequest request) {
    int contactId = intPathParameter(request.uri, 'contact');
    db.getContactColleagues(contactId).then((List<ReceptionColleague> receptions) {
      writeAndCloseJson(request, listReceptionColleaguesAsJson(receptions));
    }).catchError((error) {
      logger.error('contractController.getAContactsOrganizationList url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getContact(HttpRequest request) {
    int contactId = intPathParameter(request.uri, 'contact');

    db.getContact(contactId).then((Contact contact) {
      if(contact == null) {
        request.response.statusCode = 404;
        return writeAndCloseJson(request, JSON.encode({}));
      } else {
        return writeAndCloseJson(request, contactAsJson(contact));
      }
    }).catchError((error) {
      String body = '$error';
      writeAndCloseJson(request, body);
    });
  }

  void getContactList(HttpRequest request) {
    db.getContactList().then((List<Contact> list) {
      return writeAndCloseJson(request, listContactAsJson(list));
    }).catchError((error) {
      logger.error('get contact list Error: "$error"');
      Internal_Error(request);
    });
  }

  void getContactTypeList(HttpRequest request) {
    db.getContactTypeList().then((List<String> data) {
      writeAndCloseJson(request, contactTypesAsJson(data));
    }).catchError((error) {
      logger.error('contractController.getContactTypeList url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getAddressTypestList(HttpRequest request) {
    db.getAddressTypeList().then((List<String> data) {
      writeAndCloseJson(request, addressTypesAsJson(data));
    }).catchError((error) {
      logger.error('contractController.getAddressTypestList url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void getReceptionList(HttpRequest request) {
    int contactId = intPathParameter(request.uri, 'contact');

    db.getAContactsReceptionContactList(contactId).then((List<ReceptionContact_ReducedReception> data) {
      writeAndCloseJson(request, listReceptionContact_ReducedReceptionAsJson(data));
    }).catchError((error) {
      logger.error('contractController.getReceptionList url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void updateContact(HttpRequest request) {
    var contactId = intPathParameter(request.uri, 'contact');

    extractContent(request)
    .then(JSON.decode)
    .then((Map data) => db.updateContact(contactId, data['full_name'], data['contact_type'], data['enabled']))
    .then((int id) => writeAndCloseJson(request, contactIdAsJson(id)))
    .then((_) {
      Map data = {'event' : 'contactEventUpdated', 'contactEvent' : {'contactId' : contactId}};
      ORFService.Notification.broadcast(data, config.notificationServer, config.token)
        .catchError((error) {
          logger.error('updateContact Sending notification. NotificationServer: ${config.notificationServer} token: ${config.token} url: "${request.uri}" gave error "${error}"');
        });
    })
    .catchError((error) {
      logger.error('updateContact url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }
}