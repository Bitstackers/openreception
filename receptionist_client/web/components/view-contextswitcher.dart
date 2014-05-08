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

/**
 * Widget for performing UI conxtext switches.
 * 
 * Attaches event handlers on _each_ button element that listens on 
 * [event.locationChanged] in order for them to assert their visual representation.
 */
class ContextSwitcher {
  
  static const String className = '${libraryName}.ContextSwitcher';
  
  UListElement                 element;

  ContextSwitcher(UListElement this.element, List<Context> contexts) {
    
    const context = '${className}.ContextSwitcher';  
    
    for(Context uiContext in contexts) {
      ButtonElement existingElement = querySelector ('#${uiContext.id}_switcherbutton');
      
      existingElement..onClick.listen((_) => Controller.Context.change(uiContext));
      event.bus.on(event.locationChanged).listen((nav.Location newlocation) { 
        existingElement.classes.toggle('active', newlocation.contextId == uiContext.id);
        });
    }
  }
}
