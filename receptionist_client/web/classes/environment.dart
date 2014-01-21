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

library environment;

//import 'dart:async';
//import 'dart:collection';

//import 'common.dart';
//import 'context.dart';
import 'events.dart' as event;
//import 'logger.dart';
import 'model.dart' as model;
//import 'state.dart';

String     _activeWidget = '';
String get activeWidget => _activeWidget;
void   set activeWidget(String widget) {
  _activeWidget = widget;
  event.bus.fire(event.activeWidgetChanged, widget);
}

//@observable
model.Call             call             = model.nullCall;
//@observable model.CallList         callQueue        = new model.CallList();
//@observable model.CallList         localCallQueue   = new model.CallList();

model.Contact     _contact = model.nullContact;
model.Contact get contact  => _contact;
void          set contact(model.Contact contact) {
  _contact = contact;
//  event.bus.fire(event.contactChanged, contact);
}

model.Reception     _reception = model.nullReception;
model.Reception get reception  => _reception;
void               set reception(model.Reception reception) {
  _reception = reception;
//  event.bus.fire(event.receptionChanged, reception);
}

model.ReceptionList     _receptionList = new model.ReceptionList();
model.ReceptionList get receptionList  => _receptionList;
void                   set receptionList(model.ReceptionList receptionList) {
  _receptionList = receptionList;
}
