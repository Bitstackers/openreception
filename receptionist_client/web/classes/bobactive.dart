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

library BobActive;

import 'dart:html';

import 'context.dart';
import 'events.dart' as event;
import 'state.dart';
import '../components.dart';

class BobActive {
  DivElement element;

  BobActive(DivElement this.element) {
    assert(element != null);

    event.bus.on(event.stateUpdated).listen((State value) => element.classes.toggle('hidden', !value.isOK));

    new ContextSwitcher(querySelector('#contextswitcher'), registerContexts());
    new WelcomeMessage(querySelector('#welcomemessage'));
    new AgentInfo(querySelector('#agentinfo'));
    new CompanySelector(querySelector('#companyselector'));
    new CompanyEvents(querySelector('#companyevents'));
  }

  List<Context> registerContexts() {
    return querySelectorAll('#bobactive > section')
        .map((section) => new Context(section)).toList(growable: false);
  }
}
