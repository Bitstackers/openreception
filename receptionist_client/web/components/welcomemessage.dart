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

part of view;

const String EMPTY_FIELD = '';

/**
 * Widget for displaying greetings for 
 */
class WelcomeMessage {
  DivElement container;
  SpanElement get message => container.querySelector('#welcome-message-text');

  /**
   * 
   */
  WelcomeMessage(DivElement this.container) {
    event.bus.on(event.receptionChanged).listen(this._onReceptionChange);

    event.bus.on(model.Call.currentCallChanged).listen(_onCallChange);
  }

  /**
   * 
   */
  void _onReceptionChange(model.Reception reception) {
    this._render(reception != model.nullReception ? reception.greeting : EMPTY_FIELD);
  }

  /**
   * Marks the widget as being active.
   * TODO: Introduce variable greeting depending on if the welcomeMessage have been played. Different texts for the situations.
   */
  void _onCallChange(model.Call call) {
    log.debugContext("Changed to call ${call.ID}", "WelcomeMessage");
    
    container.classes.toggle('welcome-message-active-call', call != model.nullCall);
    
    if (call != model.nullCall ) {  
      return;
    }
    if (call != model.nullCall && call.greetingPlayed) {
        model.Reception.get(call.receptionId).then((model.Reception reception) {
          this._render(!call.greetingPlayed ? reception.greeting : reception.alternateGreeting);
        });
    }
  }

  /**
   * 
   */
  void _render(String newTitle) {
    message.text = newTitle;
  }
}
