/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

import 'dart:async';

import 'dart:html';

import 'package:polymer/polymer.dart';

import '../classes/common.dart';
import '../classes/events.dart' as event;
import '../classes/logger.dart';
import '../classes/model.dart' as model;
import '../classes/storage.dart' as storage;

@CustomTag('company-selector')
class CompanySelector extends PolymerElement with ApplyAuthorStyle {
  final       String                 defaultOptionText = 'vælg virksomhed';
              model.Organization     nullOrganization  = model.nullOrganization;
  @observable model.Organization     organization      = model.nullOrganization;
  @observable model.OrganizationList organizationList  = new model.OrganizationList();

  CompanySelector.created() : super.created() {
    _registerEventHandlers();
    _initialFill();
  }

  void _initialFill() {
    storage.getOrganizationList().then((model.OrganizationList list) {
      organizationList = list;

      log.debug('CompanySelector._initialFill updated organizationList');
    }).catchError((error) {
      log.critical('CompanySelector._initialFill storage.getOrganizationList failed with ${error}');
    });
  }

  void selection(Event e, var detail, Node target) {
    SelectElement element = target;

    try {
      int id = int.parse(element.value);

      storage.getOrganization(id).then((model.Organization org) {
        event.bus.fire(event.organizationChanged, org);

        log.debug('CompanySelector._selection updated organization to ${organization}');
      }).catchError((error) {
        event.bus.fire(event.organizationChanged, model.nullOrganization);

        log.critical('CompanySelector._selection storage.getOrganization failed with ${error}');
      });
    } on FormatException {
      event.bus.fire(event.organizationChanged, model.nullOrganization);

      log.critical('CompanySelector._selection storage.getOrganization SelectElement has bad value: ${element.value}');
    }
  }

  void _registerEventHandlers() {
    event.bus.on(event.organizationChanged).listen((model.Organization org) {
      organization = org;
    });

    event.bus.on(event.organizationListChanged).listen((model.OrganizationList list) {
      organizationList = list;
    });
  }
}
