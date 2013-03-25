import 'dart:html';
import 'package:web_ui/web_ui.dart';

import '../classes/configuration.dart';
import '../classes/section.dart';

class Bob extends WebComponent {
  bool get configurationLoaded => configuration.loaded;
}
