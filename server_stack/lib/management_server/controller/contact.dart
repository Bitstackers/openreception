library contactController;

import 'dart:io';
import 'dart:convert';

import '../view/colleague.dart';
import '../configuration.dart';
import '../view/contact.dart';
import '../database.dart';
import '../model.dart' as model;
import '../router.dart';
import '../view/organization.dart';
import '../view/reception_contact_reduced_reception.dart';
import 'package:openreception_framework/common.dart' as orf;
import 'package:openreception_framework/event.dart' as orf_event;
import 'package:openreception_framework/model.dart' as Model;
import 'package:openreception_framework/httpserver.dart' as orf_http;

const libraryName = 'contactController';

class ContactController {
  final Database db;
  final Configuration config;

  ContactController(Database this.db, Configuration this.config);

  void getAContactsOrganizationList(HttpRequest request) {
    const String context = '${libraryName}.getAContactsOrganizationList';
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getAContactsOrganizationList(contactId).then((List<model.Organization> organizations) {
      orf_http.writeAndClose(request, listOrganizatonAsJson(organizations));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }

  void getColleagues(HttpRequest request) {
    const String context = '${libraryName}.getColleagues';
    final int contactId = orf_http.pathParameter(request.uri, 'contact');

    db.getContactColleagues(contactId).then((List<model.ReceptionColleague> receptions) {
      orf_http.writeAndClose(request, listReceptionColleaguesAsJson(receptions));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
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

    db.getAContactsReceptionContactList(contactId).then((List<model.ReceptionContact_ReducedReception> data) {
      orf_http.writeAndClose(request, listReceptionContact_ReducedReceptionAsJson(data));
    }).catchError((error) {
      orf.logger.errorContext('url: "${request.uri}" gave error "${error}"', context);
      orf_http.serverError(request, error.toString());
    });
  }
}
