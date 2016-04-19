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

library openreception.service.html;

import 'dart:async';
import 'dart:html' as HTML;
import 'service.dart' as Service;
import 'package:logging/logging.dart';

part 'service/html/service-html-client.dart';
part 'service/html/service-html-websocket_client.dart';


final String libraryName = "openreception.service.html";