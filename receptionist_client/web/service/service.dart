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

library service;

import 'dart:async';

import '../model/model.dart' as Model;

import 'package:logging/logging.dart';

import 'package:openreception_framework/bus.dart';
import 'package:openreception_framework/event.dart'   as OREvent;
import 'package:openreception_framework/service.dart' as ORService;

part 'service-notification.dart';

const String libraryName = "service";
