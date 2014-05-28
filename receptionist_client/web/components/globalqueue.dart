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

  static const String className = '${libraryName}.GlobalQueue';

  Context context;
  DivElement element;
  bool hasFocus = false;
  HeadingElement header;
  final String title = 'Global kø';
  UListElement ul;
  model.CallList _callList;
  int callCount = 0;

  GlobalQueue(DivElement this.element, Context this.context) {
    header = querySelector("#globalqueue").querySelector('h1');
    header.text = this.title;

    ul = querySelector("#globalqueue").querySelector('ul');

    registerEventListerns();
    _initialFill();
  }

  void registerEventListerns() {
    model.CallList.instance.events.on(model.CallList.insert).listen(addCall);
    model.CallList.instance.events.on(model.CallList.delete).listen((_) { this.updateHeaderText();});

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

  }

  void _initialFill() {
    model.CallList.instance.reloadFromServer().then((model.CallList callList) {
      for (var call in callList) {
        addCall(call);
        this.callCount++;
      }
    });
    
    updateHeaderText();
  }

  void addCall(model.Call call) {
    Call callView = new Call(call);
    
    call.events.on(model.Call.answered).listen((_) {
      callView._callQueueRemoveHandler(_); 
      this.updateHeaderText();
    });
    call.events.on(model.Call.hungup).listen((_) {
      callView._callHangupHandler(_);
      this.updateHeaderText();
    });
    
    callView.element.hidden = call.state == model.CallState.SPEAKING || call.state == model.CallState.PARKED;
    
    ul.children.add(callView.element);
  }

  void queueItemClickHandler(MouseEvent mouseEvent, Call queueItem) {
    queueItem.call.pickup();
  }

  void updateHeaderText() {
    header.text = '${title} (${this.ul.children.where((LIElement element) => !element.hidden).length}) ${new DateTime.now()}';
  }
}
