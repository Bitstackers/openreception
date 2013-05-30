import 'dart:async';
import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/keyboardhandler.dart';
import '../classes/model.dart' as model;

class CompanyEvents extends WebComponent {
  String title = 'Kalender';

  created() {
    keyboardHandler.onKeyName('companyevents').listen((_) => environment.widgetFocus = 'companyevents');
  }

  void foo(int keyCode) {
    if(environment.organization.current != model.nullOrganization) {
//      this.query('ul').tabIndex = 0;  This works for focus, but is somewhat ugly.
//      this.query('ul').focus();

      print('arrowUp');
    }
  }
}
