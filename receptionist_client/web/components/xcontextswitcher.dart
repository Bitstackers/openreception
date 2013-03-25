import 'dart:html';
import 'package:web_ui/web_ui.dart';

import '../classes/section.dart';

class ContextSwitcher extends WebComponent {
  List<Section> sectionList = <Section>[];

  void inserted() {
    for (var elem in queryAll('section')..where((v) => v.id.startsWith('context'))) {
      sectionList.add(new Section(elem));
    }
  }
}
