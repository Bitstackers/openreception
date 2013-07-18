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

import 'package:web_ui/web_ui.dart';

import '../classes/logger.dart';
import '../classes/state.dart';

class BobDisaster extends WebComponent {
  final String text = "We're in disaster mode...";

  void created() {
    new Timer.periodic(new Duration(milliseconds: 1000), (Timer timer) {
      if (state.isOK) {
        timer.cancel();
        log.info('This is not the disaster you are looking for.');
      } else {
        log.info('DISASTER MODE TESTING');
      }
    });
  }
}
