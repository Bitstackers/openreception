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
 * Widget for performing UI conxtext switches.
 *
 * Attaches event handlers on _each_ button element that listens on
 * [event.locationChanged] in order for them to assert their visual representation.
 */
class ContextSwitcher {

  static const String className = '${libraryName}.ContextSwitcher';

  UListElement                 element;
  List<Element>  get nuges => this.element.querySelectorAll('.nudge');

  ContextSwitcher(UListElement this.element, List<Context> contexts) {

    const context = '${className}.ContextSwitcher';

    List<String> shortCuts = ['Q','W','E','R'];

    int index = 0;
    for(Context uiContext in contexts) {
      ButtonElement existingElement = querySelector ('#${uiContext.id}_switcherbutton');

      if (index < shortCuts.length) {

        existingElement.parent.insertBefore(new Nudge(shortCuts[index]).element, existingElement);

        keyboardHandler.registerNavShortcut(shortCuts[index], (_) => Controller.Context.change(uiContext));

        index++;
      }

      existingElement..onClick.listen((_) => Controller.Context.change(uiContext));

      event.bus.on(event.locationChanged).listen((nav.Location newlocation) =>
        existingElement.classes.toggle('active', newlocation.contextId == uiContext.id));


    }

    this._registerEventListeners();
  }

  void hideNudges(bool hidden) {
    nuges.forEach((Element element) {
      element.hidden = hidden;
    });
  }

  void _registerEventListeners() {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.hideNudges(!isPressed));
  }

}
