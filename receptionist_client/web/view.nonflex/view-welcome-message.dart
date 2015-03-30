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

part of view;

/**
 * Widget for displaying greetings for
 */
class WelcomeMessage {
  DivElement container;
  SpanElement get message => container.querySelector('#${Id.welcomeMessageText}');

  /**
   *
   */
  WelcomeMessage(DivElement this.container) {
    event.bus.on(model.Reception.activeReceptionChanged).listen(this._onReceptionChange);

    event.bus.on(model.Call.currentCallChanged).listen(_onCallChange);
  }

  /**
   *
   */
  void _onReceptionChange(model.Reception reception) {
    if (model.Call.currentCall != model.nullCall) {
      if (reception == model.Reception.noReception) {
         log.error('Changing to null reception while in call - very suspicius.');
      } else {
        if (model.Call.currentCall.greetingPlayed) {
          this._render(reception.shortGreeting);
        } else {
          this._render(reception.greeting);
        }
      }
    } else {
      this._render(reception.greeting);
    }
  }

  /**
   * Marks the widget as being active.
   */
  void _onCallChange(model.Call call) {
    log.debugContext("Changed to call ${call.ID}", "WelcomeMessage");

    container.classes.toggle(CssClass.welcomeMessageActiveCall, call != model.nullCall);

    if (call != model.nullCall && call.greetingPlayed) {
      storage.Reception.get(call.receptionId).then((model.Reception reception) {
          this._render(!call.greetingPlayed ? reception.greeting : reception.shortGreeting);
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
