library section;

import 'dart:async';
import 'dart:html';

final StreamController<String> _sectionActivationStream = new StreamController<String>.broadcast();

/**
 * A [Section] is a container for some content. A [Section] can be active or
 * inactive, defined by the [isActive] property.
 */
class Section {
  Element element;
  bool isActive = false;

  String get id => element.id;
  Stream get stream => _sectionActivationStream.stream;

  Section(Element this.element) {
    assert(element != null);

    isActive = element.classes.contains('hidden') ? false : true;

    _sectionActivationStream.stream.listen(_toggle);
  }

  void _toggle(String sectionId) {
    if (sectionId == id) {
      isActive = true;
      element.classes.remove('hidden');
    } else if (isActive) {
      isActive = false;
      element.classes.add('hidden');
    }
  }

  void activate() {
    _sectionActivationStream.sink.add(id);
  }
}
