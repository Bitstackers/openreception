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

final HotKeys  _hotKeys  = new HotKeys();
final Navigate _navigate = new Navigate();

abstract class Widget {
  /**
   * SHOULD return the widgets [Place]. MAY return null if the widget has no
   * [Place] associated with it.
   */
  Place   get myPlace;
  UIModel get ui;

  /**
   * Tab from first to last tab element when first is in focus an a Shift+Tab
   * event is caught.
   */
  void handleShiftTab(KeyboardEvent event) {
    if(ui.active && ui.focusIsOnFirst) {
      event.preventDefault();
      ui.tabToLast();
    }
  }

  /**
   * Tab from last to first tab element when last is in focus an a Tab event
   * is caught.
   */
  void handleTab(KeyboardEvent event) {
    if(ui.active && ui.focusIsOnLast) {
      event.preventDefault();
      ui.tabToFirst();
    }
  }

  /**
   * Navigate to [myPlace] if widget is not already in focus.
   */
  void navigateToMyPlace() {
    if(!ui.active) {
      _navigate.go(myPlace);
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
}
