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
  Box         box;
  DivElement  container;
  DivElement  element;
  SpanElement message;

  WelcomeMessage(DivElement this.element) {
    String html = '''
      <div>
        <span></span>
      </div>
    ''';

    container = new DocumentFragment.html(html).querySelector('div');
    message = container.querySelector('div > span');

    box = new Box.noChrome(element, container);

    event.bus.on(event.organizationChanged)
      .listen((model.Organization org) => message.text = org != model.nullOrganization ? org.greeting : '');

    event.bus.on(event.callChanged).listen((model.Call value) {
      element.classes.toggle('welcome-message-active-call', value != model.nullCall);
    });
  }
}
