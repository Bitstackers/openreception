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
 *
 */
class CallList {

  static const String className = '${libraryName}.CallList';

  Context context;
  Element element;
  bool hasFocus = false;

  Element        get header       => this.element.querySelector('legend');
  UListElement   get queuedCallUL => this.element.querySelector('#${Id.globalCallQueueList}');
  UListElement   get ownedCallsUL => querySelector("#local-call-list"); //TODO: Move this to a more local DOM scope.

  Element        get localCallsHeader => querySelector("#local-calls legend"); //TODO: Move this to a more local DOM scope.

  int callCount = 0;

  CallList(Element this.element, Context this.context) {
    this._registerEventListerns();
    this._renderHeader();
  }

  void _registerEventListerns() {
    model.CallList.instance.events.on(model.CallList.insert).listen((model.Call call) {
      this._renderCall(call, this.queuedCallUL);
    });

    model.CallList.instance.events.on(model.CallList.delete).listen((_) {
      this._renderHeader();
    });

    model.CallList.instance.events.on(model.CallList.reload).listen(this.renderList);

    context.registerFocusElement(queuedCallUL);
  }

  void renderList(model.CallList callList) {
    callList.where((model.Call call) => call.availableForUser(model.User.currentUser)).forEach((model.Call call) {
      if ([model.CallState.PARKED, model.CallState.SPEAKING].contains(call.state)) {
        this._renderCall(call, this.ownedCallsUL);
      } else
        this._renderCall(call, queuedCallUL);
    });

    _renderHeader();
  }

  /**
   * Renders a [model.Call] object.
   */
  void _renderCall(model.Call call, UListElement list) {
    Call callView = new Call(call);

    call.events.on(model.Call.answered).listen((_) {
      callView._callQueueRemoveHandler(_);

      if (callView.call.assignedAgent == model.User.currentUser.ID) {
        this.queuedCallUL.children.remove(callView.element);


        this.ownedCallsUL.children.add(callView.element);
        callView.element.hidden = false;
      }
      callView.element.classes.toggle('parked', false);
      callView.element.classes.toggle('speaking', true);
      this._renderHeader();
    });

    call.events.on(model.Call.transferred).listen((_) {
      callView._callTransferHandler(_);
      this._renderHeader();
    });

    call.events.on(model.Call.queueEnter).listen((_) {
      callView.element.classes.toggle(CallCssClass.enqueued, true);
      this._renderHeader();
    });

    call.events.on(model.Call.queueLeave).listen((_) {
      callView._callTransferHandler(_);
      this._renderHeader();
    });

    call.events.on(model.Call.lock).listen((bool isLocked) {
      callView.element.classes.toggle('locked', isLocked);
      this._renderHeader();
    });

    call.events.on(model.Call.hungup).listen((_) {
      callView.element.classes.toggle('parked', false);
      callView.element.classes.toggle('speaking', false);
      callView._callHangupHandler(_);
      this._renderHeader();
    });

    call.events.on(model.Call.parked).listen((_) {
      callView.element.classes.toggle('speaking', false);
      callView.element.classes.toggle('parked', true);
      callView._renderButtons();
      this._renderHeader();
    });


    if (call.state == model.CallState.QUEUED) {
      callView.element.classes.toggle (CallCssClass.enqueued, true);
    }


//    callView.element.hidden = call.state == model.CallState.SPEAKING || call.state == model.CallState.PARKED;

    list.children.add(callView.element);
      }

  void queueItemClickHandler(MouseEvent mouseEvent, Call queueItem) {
    queueItem.call.pickup();
  }

  void _renderHeader() {
    header.children =
        [Icon.Phone,
         new SpanElement()..text = '${Label.Calls} (${this.queuedCallUL.children.where((LIElement element) => !element.hidden).length})'];

    localCallsHeader.children =
        [Icon.Exclamation,
         new SpanElement()..text = '${Label.LocalCalls} (${this.ownedCallsUL.children.where((LIElement element) => !element.hidden).length})'];

  }
}
