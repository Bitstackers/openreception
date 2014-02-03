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

part of components;

class WelcomeMessage {
  DivElement  container;
  DivElement  element;
  SpanElement message;
  model.Call  call = model.nullCall;

  WelcomeMessage(DivElement this.element) {
    message = element.querySelector('#welcome-message-text');
    
    event.bus.on(event.receptionChanged).listen((model.Reception reception) { 
        message.text = reception != model.nullReception ? reception.greeting : ''; 
      });

    event.bus.on(event.callChanged).listen((model.Call value) {
      element.classes.toggle('welcome-message-active-call', value != model.nullCall);
      if(value != model.nullCall && value.greetingPlayed) {
        //TODO Introduce variable greeting depending on if the welcomeMessage have been played.
        //Different texts for the situations.
      }
    });
  }
}
