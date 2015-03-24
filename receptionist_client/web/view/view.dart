library view;

import 'dart:async';
import 'dart:html';

import '../controller/controller.dart';

import 'package:openreception_framework/bus.dart';

part 'view-agent-info.dart';
part 'view-calendar-editor.dart';
part 'view-contact-calendar.dart';
part 'view-contact-data.dart';
part 'view-contact-list.dart';
part 'view-contexts.dart';
part 'view-context-switcher.dart';
part 'view-global-call-queue.dart';
part 'view-message-compose.dart';
part 'view-my-call-queue.dart';
part 'view-reception-calendar.dart';
part 'view-reception-commands.dart';
part 'view-reception-opening-hours.dart';
part 'view-reception-product.dart';
part 'view-reception-sales-calls.dart';
part 'view-reception-selector.dart';
part 'view-welcome-message.dart';

/**
 *
 */
final HotKeys  _hotKeys  = new HotKeys();
final Navigate _navigate = new Navigate();

/**
 * Navigates to [here] if [root] does not have the ".focus" class applied.
 */
void _activateMe(HtmlElement root, Place here) {
  if(!root.classes.contains('focus')) {
    _navigate.go(here);
  }
}

/**
 * If [place].widgetId equals [root].id then:
 *    1. Apply the ".focus" class to [root]
 *    2. Call [element].focus()
 *    3. Set tabindex="1" on all [root].querySelector('[tabindex]') elements
 *
 * If [place].widgetId DOES NOT equal [root].id then:
 *    1. Remove the ".focus" class from [root]
 *    2. Call [element].blur()
 *    3. Set tabindex="-1" on all [root].querySelector('[tabindex]') elements
 */
void _setWidgetState(HtmlElement root, HtmlElement element, Place place) {
  if(root.id == place.widgetId) {
    root.classes.toggle('focus', true);
    element.focus();
    _setTabindex(root, 1);
  } else {
    root.classes.toggle('focus', false);
    element.blur();
    _setTabindex(root, -1);
  }
}

/**
 * Set tabindex="[index]" on [root].querySelectorAll('[tabindex]')  elements.
 */
void _setTabindex(HtmlElement root, int index) {
  root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
    element.tabIndex = index;
  });
}
