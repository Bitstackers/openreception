part of usermon.view;

class CallList {
  final service.NotificationSocket _notificationSocket;
  final Logger _log = new Logger('view.CallList');
  final Map<String, Call> _callMap = {};

  final UListElement element = new UListElement();

  CallList(Iterable<model.Call> calls, this._notificationSocket) {
    element.children = calls.where(_isUnassigned).map((model.Call call) {
      _callMap[call.ID] = Call.build(call);
      return _callMap[call.ID].element;
    }).toList(growable: false);

    _registerListeners();
  }

  void _registerListeners() {
    _notificationSocket.eventStream.listen((event.Event event) {
      if (event is event.CallEvent) {
        if (event is event.CallOffer) {
          _insert(event.call);
        } else if (event is event.CallHangup) {
          _remove(event.call);
        } else {
          _update(event.call);
        }
      }
    });
  }

  void _insert(model.Call call) {
    _log.info('inserting');
    if (!_callMap.containsKey(call.ID)) {
      _callMap[call.ID] = Call.build(call);
      element.children.add(_callMap[call.ID].element);
    } else {
      _update(call);
    }
  }

  void _update(model.Call call) {
    _log.info('updating');
    if (!_isUnassigned(call)) {
      _remove(call);
    } else {
      _callMap[call.ID].call = call;
    }
  }

  void _remove(model.Call call) {
    _log.info('removing');
    if (_callMap.containsKey(call.ID)) {
      _callMap[call.ID].element.remove();
      _callMap.remove(call.ID);
    }
  }

  bool _isUnassigned(model.Call call) =>
      call.assignedTo == model.User.noID;
}
