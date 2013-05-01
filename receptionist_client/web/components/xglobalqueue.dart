import 'dart:html';
import 'dart:json' as json;

import 'package:web_ui/web_ui.dart';

import '../classes/commands.dart';
import '../classes/environment.dart' as environment;
import '../classes/logger.dart';
import '../classes/model.dart' as model;
import '../classes/notification.dart' as notify;
import '../classes/protocol.dart' as protocol;

class GlobalQueue extends WebComponent {
  @observable bool pickupButtonDisabled = false;
  @observable bool hangupButtonDisabled = true;
  @observable bool holdButtonDisabled   = true;

  List<model.Call> calls = toObservable(new List<model.Call>());

  void inserted(){
    _initialFill();
    _registerSubscribers();
  }

  void _initialFill() {
    new protocol.CallQueue()
        ..onSuccess((text){
          var callsjson = json.parse(text);
          log.debug('Initial filling of call queue gave ${callsjson['calls'].length} calls');
          for (var call in callsjson['calls']) {
            calls.add(new model.Call(call));
          }
        })
        ..onEmptyQueue((){
          log.debug('Initial Filling of callqueue. Request returned empty.');
        })
        ..onError((){
          //TODO Do Something.
        })
        ..send();
  }

  void _registerSubscribers() {
    notify.notification.addEventHandler('queue_join', _queueJoin);
    notify.notification.addEventHandler('queue_leave', _queueLeave);
    environment.call.onChange.listen(_callChange);
  }

  void _queueJoin(Map json) {
    var call = new model.Call(json['call']);

    calls.add(call);
  }

  void _queueLeave(Map json) {
    var call = new model.Call(json['call']);
    //Find the call and removes it from the calls list.
    for (var c in calls) {
      if (c.id == call.id) {
        calls.remove(c);
        break;
      }
    }
  }

  void _callChange(model.Call call){
    pickupButtonDisabled = !(call == null || call == model.nullCall);
    hangupButtonDisabled = call == null || call == model.nullCall;
    holdButtonDisabled = call == null || call == model.nullCall;
  }

  void pickupcallHandler(Event e) {
    log.debug('pickupcallHandler');
    var element = e.target as LIElement;
    //if for some strange reason the element is not a LIElement.
    if (element == null){
      log.error('pickupcallHandler is called but the target was null');
    }
    var callId = element.value;
    pickupCall(callId);
  }

  void pickupnextcallHandler() {
    log.debug('pickupnextcallHandler');
    pickupNextCall();
  }

  void hangupcallHandler() {
    log.debug('hangupcallHandler');
    hangupCall(environment.call.current.id);
  }

  void holdcallHandler() {
    log.debug('holdcallHandler');
    hangupCall(environment.call.current.id);
  }
}
