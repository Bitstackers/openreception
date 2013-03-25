import 'dart:html';
import 'package:web_ui/web_ui.dart';

import '../classes/section.dart';

class ContextSwitcher extends WebComponent {
  List<Section> get sections => sectionList;
}
