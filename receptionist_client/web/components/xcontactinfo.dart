import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/model.dart' as model;

class ContactInfo extends WebComponent {
  String calendarTitle = 'Kalender';
  String placeholder = 'søg...';
  String title = 'Medarbejdere';

  void inserted() {
    //_queryElements();
    //_registerEventListeners();
    //_resize();
  }

  void _queryElements() {

  }

  void _registerEventListeners() {
    window.onResize.listen((_) => _resize());
  }

  void _resize() {
    //this.query('[name="foo"]').style.height = '70%';
  }
}
