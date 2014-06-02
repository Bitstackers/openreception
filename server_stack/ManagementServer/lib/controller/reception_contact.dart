library receptionContactController;

import 'dart:io';
import 'dart:convert';

import '../utilities/http.dart';
import '../utilities/logger.dart';
import '../database.dart';
import '../model.dart';
import '../view/complete_reception_contact.dart';

class ReceptionContactController {
  Database db;

  ReceptionContactController(Database this.db);

  void getReceptionContact(HttpRequest request) {
    int receptionId = pathParameter(request.uri, 'reception');
    int contactId = pathParameter(request.uri, 'contact');

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
    int receptionId = pathParameter(request.uri, 'reception');

    db.getReceptionContactList(receptionId).then((List<CompleteReceptionContact> list) {
      return writeAndCloseJson(request, listReceptionContactAsJson(list));
    }).catchError((error) {
      logger.error('get reception contact list Error: "$error"');
      Internal_Error(request);
    });
  }

  void createReceptionContact(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) {
      int receptionId = pathParameter(request.uri, 'reception');
      int contactId = pathParameter(request.uri, 'contact');
      return db.createReceptionContact(receptionId, contactId, data['wants_messages'], data['phonenumbers'], data['attributes'], data['enabled']);
    })
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error(error);
      Internal_Error(request);
    });
  }

  void updateReceptionContact(HttpRequest request) {
    extractContent(request)
    .then(JSON.decode)
    .then((Map data) {
      int receptionId = pathParameter(request.uri, 'reception');
      int contactId = pathParameter(request.uri, 'contact');
      return db.updateReceptionContact(receptionId, contactId, data['wants_messages'], data['phonenumbers'], data['attributes'], data['enabled']);
    })
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error('updateReception url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }

  void deleteReceptionContact(HttpRequest request) {
    int receptionId = pathParameter(request.uri, 'reception');
    int contactId = pathParameter(request.uri, 'contact');
    db.deleteReceptionContact(receptionId, contactId)
    .then((int rowsAffected) => writeAndCloseJson(request, JSON.encode({})))
    .catchError((error) {
      logger.error('updateReception url: "${request.uri}" gave error "${error}"');
      Internal_Error(request);
    });
  }
}