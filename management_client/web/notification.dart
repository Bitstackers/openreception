library notification;

import 'dart:async';
import 'dart:html';

DivElement _box;
cancellationToken _cancelToken;

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

void _deactivateBox(String cssClass) {
  _box.classes.remove('notifyActivate');
}

void _activateBox(String cssClass) {
  _box.classes
    ..add('notifyActivate')
    ..add(cssClass);

  if(_cancelToken != null) {
    _cancelToken.deactivateToken();
  }

  cancellationToken token = new cancellationToken(() => _deactivateBox(cssClass));
  _cancelToken = token;

  new Future.delayed(new Duration(milliseconds: 5000), () {
    token.cancel();
  });
}

void info(String text) {
  _box.text = text;
  _activateBox('notificationboxinfo');
}

void error (String text) {
  _box.text = text;
  _activateBox('notificationboxerror');
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
