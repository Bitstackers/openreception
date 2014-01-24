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

class GlobalQueue {
        Box            box;
        model.Call     call      = model.nullCall;
        List<CallQueueItem> callQueue = new List<CallQueueItem>();
        Context        context;
        DivElement     element;
        bool           hasFocus = false;
        SpanElement    header;
        SpanElement    headerText;
  final String         title     = 'Global kø';
        UListElement   ul;

  // Temporary
  ButtonElement pickupnextcallbutton;
  ButtonElement hangupcallButton;
  ButtonElement holdcallButton;

  GlobalQueue(DivElement this.element, Context this.context) {
    String headerHtml = '''
      <span class="header">
        <span></span>        
        <span>
          <button id="pickupnextcallbutton">Pickup</button>
          <button id="hangupcallButton">Hangup</button>
          <button id="holdcallButton">Hold</button>
        </span>
      </span>
    ''';

    header = new DocumentFragment.html(headerHtml).querySelector('.header');

    pickupnextcallbutton = header.querySelector('#pickupnextcallbutton')
      ..onClick.listen((_) => pickupnextcallHandler())
      ..tabIndex = -1;

    hangupcallButton = header.querySelector('#hangupcallButton')
      ..onClick.listen((_) => hangupcallHandler())
      ..tabIndex = -1;

    holdcallButton = header.querySelector('#holdcallButton')
      ..onClick.listen((_) => holdcallHandler())
      ..tabIndex = -1;

    headerText = header.querySelector('span');

    ul = new UListElement()
      ..classes.add('zebra')
      ..id = 'global-queue-list';

    box = new Box.withHeader(element, header, ul);

    registerEventListerns();
    _initialFill();
  }

  void registerEventListerns() {
    event.bus.on(event.callChanged).listen((model.Call value) => call = value);
    event.bus.on(event.callQueueAdd).listen((model.Call call) => addCall(call));
    event.bus.on(event.callQueueRemove).listen((model.Call call) => removeCall(call));

    event.bus.on(event.focusChanged).listen((Focus value) {
      hasFocus = handleFocusChange(value, [ul], element);
    });

    ul.onFocus.listen((_) {
      setFocus(ul.id);
    });

    element.onClick.listen((_) {
      setFocus(ul.id);
    });

    context.registerFocusElement(ul);
    
    event.bus.on(event.pickupNextCall).listen((_) {
      pickupnextcallHandler();
    });
    
    //Keyboard Shortcuts Handlers
//    keyboardHandler.onKeyName('pickupcall').listen((_) {
//      pickupnextcallHandler();
//    });
//
//    keyboardHandler.onKeyName('parkcall').listen((_) {
//      holdcallHandler();
//    });
//
//    keyboardHandler.onKeyName('hangupcall').listen((_) {
//      hangupcallHandler();
//    });
  }

  void _initialFill() {
    protocol.callQueue().then((protocol.Response response) {
      switch(response.status) {
        case protocol.Response.OK:
          Map callsjson = response.data;
          model.CallList initialCallQueue = new model.CallList.fromJson(callsjson, 'calls');
          for(var call in initialCallQueue) {
            addCall(call);
          }
          log.debug('GlobalQueue._initialFill updated callQueue');
          break;

        default:
          log.debug('GlobalQueue._initialFill updated callQueue with empty list');
      }
      updateHeaderText();
    }).catchError((error) {
      log.critical('GlobalQueue._initialFill protocol.callQueue failed with ${error}');
    });
  }

  void _callChange(model.Call call) {
    pickupnextcallbutton.disabled = !(call == null || call == model.nullCall);
    hangupcallButton.disabled = call == null || call == model.nullCall;
    holdcallButton.disabled = call == null || call == model.nullCall;
  }

  void pickupnextcallHandler() {
    log.debug('GlobalQueue.pickupnextcallHandler');
    command.pickupNextCall();
  }

  void hangupcallHandler() {
    log.debug('GlobalQueue.hangupcallHandler');
    call.hangup();
  }

  void holdcallHandler() {
    log.debug('GlobalQueue.holdcallHandler');
    call.park();
  }

  void addCall(model.Call call) {
    CallQueueItem queueItem = new CallQueueItem(call, clickHandler);
    callQueue.add(queueItem);
    ul.children.add(queueItem.element);
    updateHeaderText();
  }

  void clickHandler(MouseEvent event, CallQueueItem queueItem) {
    if(call == null || call == model.nullCall) {
      queueItem.call.pickup();
    } else {
      log.error('Du prøver at tage et nyt kald, selv om du har en igennem.', toUserLog: true);
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
      ul.children.remove(queueItem.element);
      callQueue.remove(queueItem);
      updateHeaderText();
    }
  }

  void updateHeaderText() {
    headerText.text = '${title} (${callQueue.length})';
  }
}
