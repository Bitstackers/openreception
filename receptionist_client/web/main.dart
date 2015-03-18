import 'dart:html';

import 'classes/navigation.dart';
import 'view/view.dart';

void main() {
  Contexts contexts = new Contexts();
  ContextSwitcher contextSwitcher = new ContextSwitcher()..navigate(home);
}
