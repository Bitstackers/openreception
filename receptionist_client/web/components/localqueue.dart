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
  List<CallQueueItem> callQueue = new List<CallQueueItem>();
  String contextId;
  DivElement element;
  bool               hasFocus = false;
  String         title          = 'Lokal kø';
  UListElement ul;

  LocalQueue(DivElement this.element, String this.contextId) {
    SpanElement header = new SpanElement()
      ..text = title;

    ul = new UListElement()
      ..classes.add('zebra')
      ..id = 'local-queue-list';

    box = new Box.withHeader(element, header, ul);

    registerEventListerns();
    _initialFill();
  }

  void tabToggle(bool state) {
    ul.tabIndex = state ? getTabIndex(ul.id) : -1;
  }

  void registerEventListerns() {
    event.bus.on(event.localCallQueueAdd)
      .listen((model.Call call) => addCall(call));

    event.bus.on(event.callQueueRemove)
      .listen((model.Call call) => removeCall(call));

    event.bus.on(event.focusChanged).listen((Focus value) {
      if(value.old == ul.id) {
        hasFocus = false;
        element.classes.remove(focusClassName);
      }

      if(value.current == ul.id) {
        hasFocus = true;
        element.classes.add(focusClassName);
        ul.focus();
      }
    });

    ul.onFocus.listen((_) {
      setFocus(ul.id);
    });

    element.onClick.listen((_) {
      setFocus(ul.id);
    });

    event.bus.on(event.activeContextChanged).listen((String value) => tabToggle(contextId == value));
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
    var queueItem = new CallQueueItem(call);
    callQueue.add(queueItem);
    ul.children.add(queueItem.element);
  }

  void removeCall(model.Call call) {
    CallQueueItem queueItem;
    for(CallQueueItem callItem in callQueue) {
      if(callItem.call == call) {
        queueItem = callItem;
        break;
      }
    }

    if(queueItem != null) {
      ul.children.remove(queueItem.element);
      callQueue.remove(queueItem);
    }
  }
}
