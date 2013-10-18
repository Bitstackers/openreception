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

import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';

import '../classes/configuration.dart';
import '../classes/logger.dart';

@CustomTag('log-box')
class LogBox extends PolymerElement {
  bool get applyAuthorStyles => true; //Applies external css styling to component.
  List<LogRecord> messages = toObservable(new List<LogRecord>());

  void created() {
    super.created();
    log.userLogStream.listen((LogRecord record) {
      messages.insert(0, record);
      // TODO: change messages to a Queue or ListQueue as soon as support for
      // for these are added to web_ui toObservable().

      while (messages.length > configuration.userLogSizeLimit) {
        messages.removeLast();
      }
    });
  }
}
