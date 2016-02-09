library management_tool.notification;

import 'dart:async';
import 'dart:collection';
import 'dart:html';

bool _active = false;
DivElement _box;
cancellationToken _cancelToken;
Queue<String> _infoMessages = new Queue<String>();
Queue<String> _errorMessages = new Queue<String>();

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
  _infoMessages.addLast(text);
  _newMessage();
}

void error (String text) {
  _errorMessages.addLast(text);
  _newMessage();
}

void _newMessage() {
  if(!_active) {
    _displayNextMessage();
  }
}

void _displayNextMessage() {
  if(_errorMessages.isNotEmpty) {
    _activateBox(_errorMessages.removeFirst(), 'notificationboxerror', 0);

  } else if(_infoMessages.isNotEmpty) {
    _activateBox(_infoMessages.removeFirst(), 'notificationboxinfo');
  }
}

void _deactivateBox(String cssClass) {
  _active = false;
  _box.classes
    ..remove('notifyActivate')
    ..remove(cssClass);
  _displayNextMessage();
}

void _activateBox(String message, String cssClass, [int displayTime = 3000]) {
  _active = true;

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
