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

class ContextSwitcher {
  UListElement                 element;
  List<_ContextSwitcherButton> buttons = new List<_ContextSwitcherButton>();

  ContextSwitcher(UListElement this.element, List<Context> contexts) {
    for(var context in contexts) {
      LIElement contextElement = new LIElement();
      element.children.add(contextElement);
      buttons.add(new _ContextSwitcherButton(contextElement, context));
    };
  }
}

class _ContextSwitcherButton {
  ImageElement  alertImg;
  ButtonElement button;
  LIElement     element;
  ImageElement  iconActive;
  ImageElement  iconPassive;
  Context       context;

  _ContextSwitcherButton(LIElement this.element, Context this.context) {
    String html = '''
      <button id="${context.id}_switcherbutton" tabindex="-1">
        <img id="${context.id}_passive_icon" src="images/${context.id}.svg"></img>
        <img id="${context.id}_active_icon" src="images/${context.id}_active.svg"></img>
        <img id="${context.id}_alert_icon" src="images/contextalert.svg" class="hidden"></img>
      </button>
    ''';

    button = new DocumentFragment.html(html).querySelector('#${context.id}_switcherbutton')
      ..onClick.listen(clicked)
      ..onMouseOver.listen((_) => iconActive.classes.toggle('hidden', false))
      ..onMouseOut.listen((_) => iconActive.classes.toggle('hidden', true));

    iconPassive = button.querySelector('#${context.id}_passive_icon');
    iconActive = button.querySelector('#${context.id}_active_icon');
    alertImg = button.querySelector('#${context.id}_alert_icon');

    if(context.isActive) {
      button.disabled = true;
    } else {
      iconActive.classes.add('hidden');
    }

    element.children.add(button);

    registerEventListeners();
    resize();
  }

  void clicked(_) {
    if(!context.isActive) {
      context.activate();
    }
  }

  void registerEventListeners() {
    window.onResize.listen((_) => resize());

    event.bus.on(event.activeContextChanged).listen((String _) {
      iconActive.classes.toggle('hidden', !context.isActive);
      button.disabled = context.isActive;
    });

    context.bus.on(alertUpdated).listen((int value) {
      alertImg.classes.toggle('hidden', value == 0);
    });
  }

  void resize() {
    num buttonWidth = button.client.width;

    num alertSize = buttonWidth / 2;
    num buttonMargin = buttonWidth / 3;

    button.style
      ..height = '${buttonWidth}px'
      ..marginTop = '${buttonMargin}px'
      ..marginBottom = '${buttonMargin}px';

    iconActive.style
      ..height = '${buttonWidth}px'
      ..width = '${buttonWidth}px';

    iconPassive.style
      ..height = '${buttonWidth}px'
      ..width = '${buttonWidth}px';

    alertImg.style
      ..height = '${alertSize}px'
      ..width = '${alertSize}px';
  }
}
