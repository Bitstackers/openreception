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
import '../classes/model.dart' as model;
import '../classes/storage.dart' as storage;

class CompanySelector extends WebComponent {
  @observable model.OrganizationList organizationList = model.nullOrganizationList;

  const String defaultOptionText = 'vælg virksomhed';

  void created() {
    storage.organizationList.get((list) => organizationList = list);
  }

  void _selection(Event event) {
    var e = event.target as SelectElement;

    if (e.value != '') {
      storage.organization.get(int.parse(e.value),
                               (org) => environment.organization.set(org));
    }
  }
}
