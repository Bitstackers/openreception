import 'dart:html';
import 'package:web_ui/web_ui.dart';

import 'classes/section.dart';

void _discoverSections() {
  for (var elem in queryAll('section')..where((v) => v.id.startsWith('context'))) {
    new Section(elem);
  }
}

void main() {
  _discoverSections();
}
