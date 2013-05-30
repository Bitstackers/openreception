import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/keyboardhandler.dart';
import '../classes/model.dart' as model;

class CompanyHandling extends WebComponent {
  String title = 'Håndtering';

  created() {
    keyboardHandler.onKeyName('companyhandling').listen((_) => environment.widgetFocus = 'companyhandling');
  }
}
