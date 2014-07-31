library notification;

import 'dart:async';
import 'dart:collection';
import 'dart:html';

DivElement _box;
cancellationToken _cancelToken;
Queue<String> infoMessages = new Queue<String>();
Queue<String> errorMessages = new Queue<String>();

void initialize() {
  _box = new DivElement()
    ..classes.add('notificationbox');

  document.body.children.add(_box);

  _box.onClick.listen((_) {
    if(_cancelToken != null) {
      _cancelToken.cancel();
    }
  });
}

void info(String text) {
  infoMessages.addLast(text);
  _newMessage();
}

void error (String text) {
  errorMessages.addLast(text);
  _newMessage();
}


bool active = false;
void _newMessage() {
  if(!active) {
    _displayNextMessage();
  }
}

void _displayNextMessage() {
  if(errorMessages.isNotEmpty) {
    _activateBox(errorMessages.removeFirst(), 'notificationboxerror', 0);

  } else if(infoMessages.isNotEmpty) {
    _activateBox(infoMessages.removeFirst(), 'notificationboxinfo');
  }
}

void _deactivateBox(String cssClass) {
  active = false;
  _box.classes
    ..remove('notifyActivate')
    ..remove(cssClass);
  _displayNextMessage();
}

void _activateBox(String message, String cssClass, [int displayTime = 3000]) {
  active = true;

  _box.text = message;

  _box.classes
    ..add('notifyActivate')
    ..add(cssClass);

  if(_cancelToken != null) {
    _cancelToken.deactivateToken();
  }

  cancellationToken token = new cancellationToken(() => _deactivateBox(cssClass));
  _cancelToken = token;

  if(displayTime != null && displayTime > 0) {
    new Future.delayed(new Duration(milliseconds: displayTime), () {
      token.cancel();
    });
  }
}

class cancellationToken {
  bool cancelled = false;
  Function onCancel;

  cancellationToken(Function this.onCancel);

  void cancel() {
    if(!cancelled && onCancel != null) {
      onCancel();
    }
  }

  void deactivateToken() {
    cancelled = true;
  }
}
