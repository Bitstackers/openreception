library model;

import 'dart:html';

part 'model-dom-agent-info.dart';
part 'model-dom-calendar-editor.dart';
part 'model-dom-contact-calendar.dart';
part 'model-dom-contexts.dart';
part 'model-dom-message-compose.dart';
part 'model-dom-reception-calendar.dart';
part 'model-dom-reception-commands.dart';

abstract class DomModel {
  /**
   * SHOULD return the root element for this specific DomModel. MAY return null
   * if the root doesn't matter.
   */
  HtmlElement get root => null;
}
