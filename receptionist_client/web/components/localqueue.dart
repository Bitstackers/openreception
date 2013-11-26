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
  List<CallQueueItem> callQueue = new List<CallQueueItem>();
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
    //_initialFill();
  }

  void registerEventListerns() {
    event.bus.on(event.localCallQueueAdd).listen(addCall);
    event.bus.on(event.localCallQueueRemove).listen(removeCall);
    event.bus.on(event.callChanged).listen((model.Call value) => call = value);

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
    protocol.callLocalList(configuration.agentID).then((protocol.Response response) {
      switch(response.status) {
        case protocol.Response.OK:
          model.CallList initialCallQueue = response.data;
          for(var call in initialCallQueue) {
            addCall(call);
          }
          log.debug('LocalQueue._initialFill updated environment.localCallQueue');
          break;

        default:
          log.debug('LocalQueue._initialFill updated environment.localCallQueue with empty list');
      }
    }).catchError((error) {
      log.critical('LocalQueue._initialFill protocol.callLocalList failed with ${error}');
    });
  }

  void addCall(model.Call call) {
    CallQueueItem queueItem = new CallQueueItem(call, clickHandler)
      ..age = 0;
    callQueue.add(queueItem);
    ul.children.add(queueItem.element);

    context.increaseAlert();
  }

  void clickHandler(MouseEvent event, CallQueueItem queueItem) {
    if(call == null || call == model.nullCall) {
      queueItem.call.pickup();
    } else {
      log.debug('localqueue: clickHandler: Transfering. Got call ${call}');
      protocol.transferCall(call.bLeg, queueItem.call.id);
      log.error('Fordi du allerede har et kald igennem, bliver opkaldet, stillet videre til den du snakker med. ${queueItem.call}', toUserLog: true);
    }
  }

  void removeCall(model.Call call) {
    CallQueueItem queueItem;
    for(CallQueueItem callItem in callQueue) {
      if(callItem.call.id == call.id) {
        queueItem = callItem;
        break;
      }
    }

    if(queueItem != null) {
      context.decreaseAlert();
      ul.children.remove(queueItem.element);
      callQueue.remove(queueItem);
    }
  }
}
