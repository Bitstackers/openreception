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
 * TODO (TL): Comment
 */
class UIContexts {
  Map<String, HtmlElement> _contextMap;

  /**
   * Constructor.
   */
  UIContexts() {
    _contextMap = {Context.CalendarEdit: contextCalendarEdit,
                   Context.Home        : contextHome,
                   Context.Homeplus    : contextHomeplus,
                   Context.Messages    : contextMessages};
  }

  /// TODO (TL): get rid of the String selectors. Move to constants.dart or
  /// something similar. Perhaps use/abuse the navigation Context enum?
  HtmlElement get contextCalendarEdit => querySelector('#context-calendar-edit');
  HtmlElement get contextHome         => querySelector('#context-home');
  HtmlElement get contextHomeplus     => querySelector('#context-homeplus');
  HtmlElement get contextMessages     => querySelector('#context-messages');

  void toggleContext(Controller.Destination destination) {
    _contextMap.forEach((id, element) {
      id == destination.context ? element.style.zIndex = '1' : element.style.zIndex = '0';
    });
  }
}
