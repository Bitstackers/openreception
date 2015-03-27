library view;

import 'dart:async';
import 'dart:html';

import '../controller/controller.dart';
import '../model/model.dart';

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

abstract class Widget {
  final HotKeys  _hotKeys  = new HotKeys();
  final Navigate _navigate = new Navigate();

  bool _active = false;

  /**
   * Navigate to [myPlace] if widget is not already in focus.
   */
  void _navigateToMyPlace() {
    if(!_active) {
      _navigate.go(myPlace);
    }
  }

  void _blur() {
    _active = false;
    root.classes.toggle('focus', false);
    focusElement.blur();
    _setTabIndex(-1);
  }

  void _focus() {
    _active = true;
    root.classes.toggle('focus', true);
    focusElement.focus();
    _setTabIndex(1);
  }

  HtmlElement get focusElement;
  Place       get myPlace;
  HtmlElement get root;

  /**
   * Set tabindex="[index]" on [root].querySelectorAll('[tabindex]') elements.
   */
  void _setTabIndex(int index) {
    root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
      element.tabIndex = index;
    });
  }

  /**
   * Figure out if [place] is here and set focus and tabindexes accordingly.
   */
  void _setWidgetState(Place place) {
    if(myPlace == place) {
      _focus();
    } else {
      _blur();
    }
  }
}
