library model;

import 'dart:html';

part 'model-ui-calendar-editor.dart';
part 'model-ui-message-compose.dart';
part 'model-ui-reception-calendar.dart';
part 'model-ui-reception-commands.dart';

abstract class UIModel {
  HtmlElement get root;
}
