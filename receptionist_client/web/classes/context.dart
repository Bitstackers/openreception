library context;

import 'dart:async';
import 'dart:html';

import 'package:web_ui/web_ui.dart';

final StreamController<Context> _contextActivationStream = new StreamController<Context>();
final Stream<Context> _onChange = _contextActivationStream.stream.asBroadcastStream();

/**
 * A [Context] is a container for some content. A [Context] can be active or
 * inactive, defined by the [isActive] property.
 */
class Context {
  @observable int alertCounter = 0;
  @observable bool isActive = false;

  Element _element;

  bool   get alertMode => alertCounter > 0;
  String get id        => _element.id;

  Context(Element this._element) {
    assert(_element != null);

    isActive = _element.classes.contains('hidden') ? false : true;

    _onChange.listen(_toggle);
  }

  void _toggle(Context context) {
    if (context == this) {
      isActive = true;
      _element.classes.remove('hidden');
    } else if (isActive) {
      isActive = false;
      _element.classes.add('hidden');
    }
  }

  void activate() {
    _contextActivationStream.sink.add(this);
  }

  void decreaseAlert() {
    if (alertCounter > 0) {
      alertCounter--;  // ???? Maybe add some logging here?
    }
  }

  void increaseAlert() {
    alertCounter++; // ???? Maybe add some logging here?
  }
}
