/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library bob_disaster;

import 'dart:async';
import 'dart:html';

import 'constants.dart';
import 'events.dart' as event;
import 'state.dart';

class BobDisaster {
  DivElement element;

  BobDisaster(DivElement this.element) {
    assert(element != null);

    String baseUrl (String location)
      => location.split('?').first;


    void tryRedirect() {
      print("Retrying");
      window.location.assign(baseUrl(window.location.href));
    }

    event.bus.on(event.stateUpdated).listen((State value) {
      element.classes.toggle(CssClass.hidden, !value.isError);
      if (value.isError) {
        new Timer(new Duration(seconds: 3), tryRedirect);
      }
    });
  }
}
