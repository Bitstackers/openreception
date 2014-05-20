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

  LocalQueue(DivElement this.element, Context this.context) {
    SpanElement header = new SpanElement()
      ..text = title;

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
      log.debug('------------- components.LocalQueue Call Changed to ID: ${value.ID} Start: ${value.start} Inbound: ${value.inbound} B Leg: ${value.bLeg} Callid: ${value.callerId}');
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
  }

  void _initialFill() {
    model.CallList.instance.reloadFromServer().then((model.CallList newList) {
      newList.forEach((model.Call call) {
        addCall(call);
      });
    });
  }

  void addCall(model.Call call) {
    Call queueItem = new Call(call);
    call.events.on(model.Call.answered).listen(queueItem._callQueueRemoveHandler);
    call.events.on(model.Call.parked).listen(queueItem._callParkHandler);
    call.events.on(model.Call.hungup).listen(queueItem._callHangupHandler);
    queueItem.element.hidden = !(call.state == model.CallState.PARKED);

    ul.children.add(queueItem.element);
    context.increaseAlert();
  }

}
