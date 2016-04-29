part of usermon.view;

class CallSummary {
  int totalCalls;
  int callsAnsweredWithin20s = 0;
  int callWaitingMoreThanOneMinute = 0;
  int talkTime = 0;
}

class CallHistory {
  Map<String, model.Call> _history = {};

  Element get callsWatingMoreThanOneMinuteElement =>
      querySelector('#calls-more-than-60s');
  Element get callsAnsweredWithin20sElement =>
      querySelector('#calls-more-than-60s');

  CallHistory(service.NotificationSocket notificationSocket) {
    dispatchEvent(event.Event e) async {
      if (e is event.CallEvent && e.call.assignedTo != model.User.noId) {
        _history[e.call.ID] = e.call;
        _update();
      }
    }
    notificationSocket.eventStream.listen(dispatchEvent);
  }

  void _update() {}

  /**
   *
   */
  CallSummary get totalSummary {
    CallSummary summary = new CallSummary();
    _history.values.forEach((model.Call call) {
      final int answerLatencyInMs =
          call.answeredAt.difference(call.arrived).abs().inMilliseconds;

      if (answerLatencyInMs > 60000) {
        summary.callWaitingMoreThanOneMinute++;
      } else if (answerLatencyInMs < 20000) {
        summary.callsAnsweredWithin20s++;
      }
    });

    return summary;
  }
}
