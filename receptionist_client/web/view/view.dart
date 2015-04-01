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

final HotKeys  hotKeys  = new HotKeys();
final Navigate navigate = new Navigate();

// TODO (TL): Decide if we need to check for null on widgets that have no actual
// activation and/or no Place. It's probably a wasted check, since it will fail
// hard an early.

abstract class Widget {
  /**
   * Focus on ui.lastTabElement when ui.firstTabElement is in focus and a
   * Shift+Tab keyboard event is captured.
   */
  void handleShiftTab(KeyboardEvent event) {
    if(ui.active && ui.focusElement == ui.firstTabElement) {
      event.preventDefault();
      ui.lastTabElement.focus();
    }
  }

  /**
     * Focus on ui.firstTabElement when ui.lastTabElement is in focus and a Tab
     * keyboard event is captured.
     */
  void handleTab(KeyboardEvent event) {
    if(ui.active && ui.focusElement == ui.lastTabElement) {
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
  void navigateToMyPlace() {
    if(!ui.active) {
      navigate.go(myPlace);
    }
  }

  /**
   * Figure out if [place] is here and set focus and tabindexes accordingly.
   */
  void setWidgetState(Place place) {
    if(myPlace == place) {
      ui.focus();
    } else {
      ui.blur();
    }
  }

  UIModel get ui;
}
