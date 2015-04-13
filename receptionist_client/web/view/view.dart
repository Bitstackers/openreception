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
part 'view-contact-selector.dart';
part 'view-contexts.dart';
part 'view-global-call-queue.dart';
part 'view-message-compose.dart';
part 'view-help.dart';
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

///
///
///
/// TODO (TL): For widgets with with selectable list items, for example contact
/// and calendar lists, we have a bunch of similar functionality implemented in
/// each view object. This can and should probably be moved to ViewWidget.
///
///
///

abstract class ViewWidget {
  /**
   * SHOULD return the widgets [Place]. MAY return null if the widget has no
   * [Place] associated with it.
   */
  Place get myPlace;

  /**
   * What to do when the widget blurs.
   */
  void onBlur(Place place);

  /**
   * What to do when the widget is focused.
   */
  void onFocus(Place place);

  /**
   * MUST return the widgets [UIModel].
   */
  UIModel get ui;

  /**
   * Navigate to [myPlace] if widget is not already in focus.
   */
  void navigateToMyPlace() {
    if(!ui.active) {
      _navigate.go(myPlace);
    }
  }

  /**
   * If [place] is here:
   *  call ui.focus()
   *  call onFocus()
   *
   * if [place] is not here:
   *  call ui.blur()
   *  call onBlur();
   */
  void setWidgetState(Place place) {
    if(myPlace == place) {
      ui.focus();
      onFocus(place);
    } else {
      ui.blur();
      onBlur(place);
    }
  }
}
