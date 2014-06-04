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
 * Labels for the CallList widget.
 */
abstract class CallListLabels {
  static const String Title = 'Opkald';
}


/**
 * 
 */
class CallList {

  static const String className = '${libraryName}.CallList';

  Context context;
  DivElement element;
  bool hasFocus = false;
  
  HeadingElement get header => this.element.querySelector('h1');
  UListElement   get queuedCallUL => this.element.querySelector("#global-queue-list");
  UListElement   get ownedCallsUL => this.element.querySelector("#local-call-list");

  model.CallList _callList;
  int callCount = 0;

  CallList(DivElement this.element, Context this.context) {
    this._registerEventListerns();
    this._renderHeader;
  }

  void _registerEventListerns() {
    model.CallList.instance.events.on(model.CallList.insert).listen((model.Call call) { 
      this._addCall(call, this.queuedCallUL);
    });
    
    model.CallList.instance.events.on(model.CallList.delete).listen((_) {
      this._renderHeader();
    });

    model.CallList.instance.events.on(model.CallList.reload).listen(this.renderList);

    event.bus.on(event.focusChanged).listen((Focus value) {
      hasFocus = handleFocusChange(value, [queuedCallUL], element);
    });

    queuedCallUL.onFocus.listen((_) {
      setFocus(queuedCallUL.id);
    });

    element.onClick.listen((_) {
      setFocus(queuedCallUL.id);
    });

    context.registerFocusElement(queuedCallUL);

  }

  void renderList(model.CallList callList) {
    callList.where((model.Call call) => call.availableForUser(model.User.currentUser)).forEach((model.Call call) {
      if ([model.CallState.PARKED, model.CallState.SPEAKING].contains(call.state)) {
        this._addCall(call, this.ownedCallsUL);
      } else 
        this._addCall(call, queuedCallUL);
    });

    _renderHeader();
  }

  void _addCall(model.Call call, UListElement list) {
    Call callView = new Call(call);

    call.events.on(model.Call.answered).listen((_) {
      callView._callQueueRemoveHandler(_);
      
      if (callView.call.assignedAgent == model.User.currentUser.ID) {
        print ("!! moving call");
        this.queuedCallUL.children.remove(callView.element);
        
        
        this.ownedCallsUL.children.add(callView.element);
        callView.element.hidden = false;
      }
      
      this._renderHeader();
    });

    call.events.on(model.Call.hungup).listen((_) {
      callView._callHangupHandler(_);
      this._renderHeader();
    });

    call.events.on(model.Call.parked).listen((_) {
      callView._renderButtons();
      this._renderHeader();
    });

    event.bus.on(event.PickupFirstParkedCall).listen((_) {
      if (call.state == model.CallState.PARKED && 
          call.assignedAgent == model.User.currentUser.ID) {
        call.pickup();
        }
    });

    event.bus.on(event.TransferFirstParkedCall).listen((_) {
      if (call.state == model.CallState.PARKED && 
          call.assignedAgent == model.User.currentUser.ID) {
        call.transfer(model.Call.currentCall);
        }
    });

    
//    callView.element.hidden = call.state == model.CallState.SPEAKING || call.state == model.CallState.PARKED;

    list.children.add(callView.element);
      }

  void queueItemClickHandler(MouseEvent mouseEvent, Call queueItem) {
    queueItem.call.pickup();
  }

  void _renderHeader() {
    header.text = '${CallListLabels.Title} (${this.queuedCallUL.children.where((LIElement element) => !element.hidden).length}) ${new DateTime.now()}';
  }
}
