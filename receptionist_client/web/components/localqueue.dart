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

class LocalQueue {
  Box box;
  model.Call call = model.nullCall;
  Context context;
  DivElement element;
  bool               hasFocus = false;
  String         title          = 'Lokal kø';
  UListElement ul;
  List<Element> get nuges => this.element.querySelectorAll('.nudge');

  LocalQueue(DivElement this.element, Context this.context) {
    SpanElement header = new SpanElement()
      ..text = title;
    this.element.children.add(new View.Nudge('S').element);

    ul = new UListElement()
      ..classes.add('zebra')
      ..id = 'local-queue-list';

    box = new Box.withHeader(element, header, ul);

    context.registerFocusElement(ul);

    registerEventListerns();
    _initialFill();
  }

  void registerEventListerns() {
    model.CallList.instance.events.on(model.CallList.insert).listen(addCall);

    event.bus.on(event.callChanged).listen((model.Call value) { 
      call = value;
    });

    event.bus.on(event.focusChanged).listen((Focus value) {
      hasFocus = handleFocusChange(value, [ul], element);
    });

    ul.onFocus.listen((_) {
      setFocus(ul.id);
    });

    element.onClick.listen((_) {
      setFocus(ul.id);
    });

    event.bus.on(event.keyMeta).listen((bool isPressed) {
      this.hideNudges(!isPressed);
    });
 
  }

  void hideNudges(bool hidden) {
    nuges.forEach((Element element) {
      element.hidden = hidden;
    });
  }

  void _initialFill() {
    model.CallList.instance.reloadFromServer().then((model.CallList newList) {
      newList.forEach((model.Call call) {
        addCall(call);
      });
    });
  }

  void addCall(model.Call call) {
    Call callView = new Call(call);
    call.events.on(model.Call.answered).listen(callView._callQueueRemoveHandler);
    call.events.on(model.Call.parked).listen(callView._callParkHandler);
    call.events.on(model.Call.hungup).listen(callView._callHangupHandler);
    callView.element.hidden = !(call.state == model.CallState.PARKED);

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

    ul.children.add(callView.element);
    context.increaseAlert();
  }

}
