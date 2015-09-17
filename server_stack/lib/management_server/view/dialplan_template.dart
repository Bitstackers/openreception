/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.management_server.view.dialplantemplate;

import 'dart:convert';

import 'package:openreception_framework/model.dart';

String dialplanTemplateListAsJson(List<DialplanTemplate> list) =>
    JSON.encode({'templates': _dialplanTemplateListAsJsonList(list)});

Map _dialplanTemplateAsJsonMap(DialplanTemplate template) => template == null ? {} :
    {'id': template.id,
     'template': template.template};

List _dialplanTemplateListAsJsonList(List<DialplanTemplate> templates) =>
    templates.map(_dialplanTemplateAsJsonMap).toList();
