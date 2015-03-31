library view;

import 'dart:async';
import 'dart:html';

import '../controller/controller.dart';
import '../model/model.dart' as Model;

import 'package:openreception_framework/bus.dart';

part 'view-agent-info.dart';
part 'view-calendar-editor.dart';
part 'view-contact-calendar.dart';
part 'view-contact-data.dart';
part 'view-contact-list.dart';
part 'view-contexts.dart';
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

final HotKeys  _hotKeys  = new HotKeys();
final Navigate _navigate = new Navigate();

// TODO (TL): Decide if we need to check for null on widgets that have no actual
// activation and/or no Place. It's probably a wasted check, since it will fail
// hard an early.

abstract class Widget {
  /// TODO (TL): Perhaps move this to DOM?
  bool _active = false;

  /**
   * Blur the widget.
   */
  void _blur() {
    _active = false;
    ui.root.classes.toggle('focus', false);
    ui.focusElement.blur();
    _setTabIndex(-1);
  }

  /**
   * Focus the widget.
   */
  void _focus() {
    _active = true;
    ui.root.classes.toggle('focus', true);
    ui.focusElement.focus();
    _setTabIndex(1);
  }

  /**
   * Focus on [_lastTabElement] when [_firstTabElement] is in focus and a
   * Shift+Tab keyboard event is captured.
   */
  void _handleShiftTab(KeyboardEvent event) {
    if(_active && ui.focusElement == ui.firstTabElement) {
      event.preventDefault();
      ui.lastTabElement.focus();
    }
  }

  /**
     * Focus on [_firstTabElement] when [_lastTabElement] is in focus and a Tab
     * keyboard event is captured.
     */
  void _handleTab(KeyboardEvent event) {
    if(_active && ui.focusElement == ui.lastTabElement) {
      event.preventDefault();
      ui.firstTabElement.focus();
    }
  }

  /**
   * SHOULD return the widgets [Place]. MAY return null if the widget has no
   * [Place] associated with it.
   */
  Place get myPlace;

  /**
   * Navigate to [myPlace] if widget is not already in focus.
   */
  void _navigateToMyPlace() {
    if(!_active) {
      _navigate.go(myPlace);
    }
  }

  /**
   * Set tabindex="[index]" on [root].querySelectorAll('[tabindex]') elements.
   */
  void _setTabIndex(int index) {
    ui.root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
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

  UIModel get ui;
}
