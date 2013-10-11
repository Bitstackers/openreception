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

//import 'dart:html';

import 'package:polymer/polymer.dart';

import '../classes/environment.dart' as environment;
import '../classes/events.dart' as event;

//@CustomTag('context-switcher')
//class ContextSwitcher extends PolymerElement {
//  void created(){
//    print('contextswitcher created');
//  }
//}

@CustomTag('context-switcher')
class ContextSwitcher extends PolymerElement {
  @observable environment.ContextList contextList;

  bool get applyAuthorStyles => true; //Applies external css styling to component.
  
  void created() {
    super.created();
    print('contextswitcher created');
    
    event.bus.on(event.contextListUpdated).listen((environment.ContextList list) {
      contextList = list;
    });
  }
  
  void inserted(){
    print("context switcher inserted");
  }
}
