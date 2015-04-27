library view;

import 'dart:async';
import 'dart:html';

import '../controller/controller.dart' as Controller;
import '../dummies.dart';
import '../enums.dart';
import '../model/model.dart' as Model;

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
part 'view-reception-addresses.dart';
part 'view-reception-alt-names.dart';
part 'view-reception-bank-info.dart';
part 'view-reception-calendar.dart';
part 'view-reception-commands.dart';
part 'view-reception-email.dart';
part 'view-reception-mini-wiki.dart';
part 'view-reception-opening-hours.dart';
part 'view-reception-product.dart';
part 'view-reception-salesmen.dart';
part 'view-reception-selector.dart';
part 'view-reception-telephone-numbers.dart';
part 'view-reception-type.dart';
part 'view-reception-vat-numbers.dart';
part 'view-reception-websites.dart';
part 'view-receptionistclient-ready.dart';
part 'view-receptionistclient-disaster.dart';
part 'view-receptionistclient-loading.dart';
part 'view-welcome-message.dart';

final Controller.HotKeys  _hotKeys  = new Controller.HotKeys();
final Controller.Navigate _navigate = new Controller.Navigate();

/**
 * TODO (TL): Comment
 */
abstract class ViewWidget {
  /**
   * SHOULD return the widgets [Destination]. MAY return null if the widget has
   * no [Destination] associated with it.
   */
  Controller.Destination get myDestination;

  /**
   * What to do when the widget blurs.
   */
  void onBlur(Controller.Destination destination);

  /**
   * What to do when the widget is focused.
   */
  void onFocus(Controller.Destination destination);

  /**
   * MUST return the widgets [UIModel].
   */
  Model.UIModel get ui;

  /**
   * Navigate to [myDestination] if widget is not already in focus.
   */
  void navigateToMyDestination() {
    if(!ui.isFocused) {
      _navigate.go(myDestination);
    }
  }

  /**
   * If [destination] is here:
   *  call ui.focus()
   *  call onFocus()
   *
   * if [destination] is not here:
   *  call ui.blur()
   *  call onBlur();
   */
  void setWidgetState(Controller.Destination destination) {
    if(myDestination == destination) {
      ui.focus();
      onFocus(destination);
    } else {
      ui.blur();
      onBlur(destination);
    }
  }
}
