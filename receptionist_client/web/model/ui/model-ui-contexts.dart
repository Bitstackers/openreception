/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

/**
 * Toggle visibility of contexts. Basically all this does is set the z-index
 * to 1 of the latest [Controller.Destination].context and z-index 0 on all
 * other contexts.
 */
class UIContexts {
  Map<Controller.Context, HtmlElement> _contextMap;

  /**
   * Constructor.
   */
  UIContexts() {
    _contextMap = {
      Controller.Context.calendarEdit: contextCalendarEdit,
      Controller.Context.home: contextHome,
      Controller.Context.homePlus: contextHomeplus,
      Controller.Context.messages: contextMessages
    };
  }

  HtmlElement get contextCalendarEdit => querySelector('#context-calendar-edit');
  HtmlElement get contextHome => querySelector('#context-home');
  HtmlElement get contextHomeplus => querySelector('#context-homeplus');
  HtmlElement get contextMessages => querySelector('#context-messages');

  /**
   * Make [destination].context visible and all other contexts invisible.
   */
  void toggleContext(Controller.Destination destination) {
    _contextMap.forEach((id, element) {
      id == destination.context ? element.style.zIndex = '1' : element.style.zIndex = '0';
    });
  }
}
