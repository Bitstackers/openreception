import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/model.dart' as model;

class CalendarEvent extends WebComponent {
  model.CalendarEvent event;

  String get notactive => event.active ? '' : 'notactive';
}
