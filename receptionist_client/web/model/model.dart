library model;

import 'dart:async';
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
  HtmlElement _firstTabElement;
  HtmlElement _focusElement;
  HtmlElement _lastTabElement;

  HtmlElement get _root;

  /**
   * Return true if the widget is in focus.
   */
  bool get active => _root.classes.contains('focus');

  /**
   * Blur the widget and set tabindex to -1.
   */
  void blur() {
    _root.classes.toggle('focus', false);
    _focusElement.blur();
    _setTabIndex(-1);
  }

  /**
   * Focus the widget and set tabindex to 1.
   */
  void focus() {
    _setTabIndex(1);
    _root.classes.toggle('focus', true);
    _focusElement.focus();
  }

  /**
   * Return true if the currently focused element is the first element with
   * tabindex set for this widget.
   */
  bool get focusIsOnFirst => _focusElement == _firstTabElement;

  /**
   * Return true if the currently focused element is the last element with
   * tabindex set for this widget.
   */
  bool get focusIsOnLast  => _focusElement == _lastTabElement;

  /**
   * Set tabindex="[index]" on [root].querySelectorAll('[tabindex]') elements.
   */
  void _setTabIndex(int index) {
    _root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
      element.tabIndex = index;
    });
  }

  /**
   * Focus the first element with tabindex set for this widget.
   */
  void tabToFirst() {
    _firstTabElement.focus();
  }

  /**
   * Focus the last element with tabindex set for this widget.
   */
  void tabToLast() {
    _lastTabElement.focus();
  }
}

enum AgentState {BUSY, IDLE, PAUSE, UNKNOWN}
enum AlertState {OFF, ON}
