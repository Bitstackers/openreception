part of usermon.view;

class CallList {
  final or_service.NotificationSocket _notificationSocket;
  final Logger _log = new Logger('view.CallList');
  final Map<String, Call> _callMap = {};

  final UListElement element = new UListElement();

  CallList(Iterable<or_model.Call> calls, this._notificationSocket) {
    element.children = calls.where(_isUnassigned).map((or_model.Call call) {
      _callMap[call.ID] = Call.build(call);
      return _callMap[call.ID].element;
    }).toList(growable: false);

    _registerListeners();
  }

  void _registerListeners() {
    _notificationSocket.eventStream.listen((or_event.Event event) {
      if (event is or_event.CallEvent) {
        if (event is or_event.CallOffer) {
          _insert(event.call);
        } else if (event is or_event.CallHangup) {
          _remove(event.call);
        } else {
          _update(event.call);
        }
      }
    });
  }

  void _insert(or_model.Call call) {
    _log.info('inserting');
    if (!_callMap.containsKey(call.ID)) {
      _callMap[call.ID] = Call.build(call);
      element.children.add(_callMap[call.ID].element);
    } else {
      _update(call);
    }
  }

  void _update(or_model.Call call) {
    _log.info('updating');
    if (!_isUnassigned(call)) {
      _remove(call);
    } else {
      _callMap[call.ID].call = call;
    }
  }

  void _remove(or_model.Call call) {
    _log.info('removing');
    if (_callMap.containsKey(call.ID)) {
      _callMap[call.ID].element.remove();
      _callMap.remove(call.ID);
    }
  }

  bool _isUnassigned(or_model.Call call) =>
      call.assignedTo == or_model.User.noID;
}
