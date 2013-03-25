library section;

import 'dart:async';
import 'dart:html';
import 'package:web_ui/web_ui.dart';

List<Section> sectionList = <Section>[];

final StreamController _sectionActivationStream = new StreamController<int>.broadcast();

/**
 * A [Section] is a container for some content. A [Section] can be active or
 * inactive, defined by the [isActive] property.
 */
@observable
class Section {
  Element element;
  bool isActive = false;

  int get id => this.hashCode;

  Section(Element this.element) {
    assert(element != null);

    sectionList.add(this);

    isActive = element.classes.contains('hidden') ? false : true;

    _sectionActivationStream.stream.listen(_toggle);
  }

  void _toggle(int sectionID) {
    if (sectionID == id) {
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
