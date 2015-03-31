library model;

import 'dart:html';

part 'model-ui-agent-info.dart';
part 'model-ui-calendar-editor.dart';
part 'model-ui-contact-calendar.dart';
part 'model-ui-contact-data.dart';
part 'model-ui-contact-list.dart';
part 'model-ui-contexts.dart';
part 'model-ui-message-compose.dart';
part 'model-ui-reception-calendar.dart';
part 'model-ui-reception-commands.dart';

abstract class UIModel {
  bool        get active => root.classes.contains('focus');
  HtmlElement get firstTabElement;
  HtmlElement get focusElement;
  HtmlElement get lastTabElement;
  HtmlElement get root;

  set firstTabElement(HtmlElement element);
  set focusElement   (HtmlElement element);
  set lastTabElement (HtmlElement element);

  void blur() {
    root.classes.toggle('focus', false);
    focusElement.blur();
    _setTabIndex(-1);
  }

  void focus() {
    root.classes.toggle('focus', true);
    focusElement.focus();
    _setTabIndex(1);
  }

  /**
   * Set tabindex="[index]" on [root].querySelectorAll('[tabindex]') elements.
   */
  void _setTabIndex(int index) {
    root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
      element.tabIndex = index;
    });
  }
}

enum AgentState {BUSY, IDLE, PAUSE, UNKNOWN}
enum AlertState {OFF, ON}
