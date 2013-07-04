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

import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/logger.dart';
import '../classes/model.dart' as model;
import '../classes/storage.dart' as storage;

class CompanySelector extends WebComponent {
  final String defaultOptionText = 'vælg virksomhed';

  void created() {
    storage.getOrganizationList().then((model.OrganizationList list) {
      environment.organizationList = list;
    }).catchError((error) {
      log.error('CompanySelector ERROR storage.getOrganizationList failed with ${error}');
    });
  }

  void _selection(Event event) {
    var e = event.target as SelectElement;

    if (e.value != '') {
      storage.getOrganization(int.parse(e.value)).then((model.Organization org) {
        environment.organization = org;
        log.info('CompanySelector updated environment.organization to ${org}');
      }).catchError((error) {
        log.error('CompanySelector ERROR storage.getOrganization failed with ${error}');
      });
    }
  }
}
