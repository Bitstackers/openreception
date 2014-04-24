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

/**
 * 
 */

class CallManagement {
  
  static final String     id        = constant.ID.CALL_MANAGEMENT;
  static final String     className = '${libraryName}.CallManagement'; 
         final DivElement node;

  /**
   * TODO
   */
  CallManagement(DivElement this.node) {
    registerEventListeners();
    _updateCallInfo(model.nullCall);
  }

  _updateCallInfo(model.Call call) {
    String newText;
    
    if (call != model.nullCall) {
      newText = call.otherLegCallerID();
    } else {
      newText = constant.Label.NOT_IN_CALL;
    }
    
    print("Updated call text with $newText");
    this.node.querySelector('#current-call-info').text = newText;
  }
  void registerEventListeners() {
    //TODO: Listen on model changes.
    event.bus..on(event.callChanged).listen(_updateCallInfo);
    
  }
}
