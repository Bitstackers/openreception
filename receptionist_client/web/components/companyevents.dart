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

import 'package:web_ui/web_ui.dart';

import '../classes/context.dart';
import '../classes/environment.dart' as environment;
import '../classes/keyboardhandler.dart';
import '../classes/model.dart' as model;

class CompanyEvents extends WebComponent {
  Context context;
  String  title = 'Kalender';

  created() {
    _registerEventListeners();
  }

  inserted() {
    // Get the context we belong to. As all contexts currently only have one
    // layer of widgets, we can just ask for the widgets parent.id. If we ever
    // get to a point where a widget is a child of a widget and not of a context
    // then we will have to do some more advanced searching to find our the
    // context we belong to.
    //
    // We do this in inserted() because the contextList has not yet been
    // populated in created().
    context = environment.contextList.get(this.parent.id);
  }

  void _registerEventListeners() {
    keyboardHandler.onKeyName('companyevents').listen((_) {
      if (context.isActive) {
        environment.activeWidget = 'companyevents';
      }
    });
  }

  void foo(int keyCode) {
    if(environment.organization != model.nullOrganization) {
//      this.query('ul').tabIndex = 0;  This works for focus, but is somewhat ugly.
//      this.query('ul').focus();

      print('arrowUp');
    }
  }
}
