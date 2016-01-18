/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library controller;

import 'dart:async';
import 'dart:html' as Html;

import '../model/model.dart' as Model;

import 'package:okeyee/okeyee.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/bus.dart';
import 'package:openreception_framework/event.dart' as OREvent;
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:openreception_framework/service.dart' as ORService;
import 'package:openreception_framework/storage.dart' as ORStorage;

part 'controller-calendar.dart';
part 'controller-call.dart';
part 'controller-contact.dart';
part 'controller-distributionlist.dart';
part 'controller-endpoint.dart';
part 'controller-hotkeys.dart';
part 'controller-message.dart';
part 'controller-navigation.dart';
part 'controller-notification.dart';
part 'controller-popup.dart';
part 'controller-reception.dart';
part 'controller-sound.dart';
part 'controller-user.dart';

const String libraryName = 'controller';

enum Cmd {EDIT,
          NEW,
          SAVE}

class ControllerError implements Exception {

  final String message;
  const ControllerError([this.message = ""]);

  String toString() => "ControllerError: $message";
}
