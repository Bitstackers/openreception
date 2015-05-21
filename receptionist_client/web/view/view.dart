/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library view;

import 'dart:async';
import 'dart:html';

import '../controller/controller.dart' as Controller;
import '../enums.dart'; // TODO (KRC): Refactor out
import '../lang.dart';
import '../model/model.dart' as Model;

import 'package:logging/logging.dart';
import 'package:openreception_framework/event.dart' as OREvent;
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:openreception_framework/util.dart' as ORUtil;

part 'view-agent-info.dart';
part 'view-calendar-editor.dart';
part 'view-contact-calendar.dart';
part 'view-contact-data.dart';
part 'view-contact-selector.dart';
part 'view-contexts.dart';
part 'view-global-call-queue.dart';
part 'view-message-compose.dart';
part 'view-hint.dart';
part 'view-message-archive.dart';
part 'view-message-archive-edit.dart';
part 'view-message-archive-filter.dart';
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

const String libraryName = "view";

final Controller.HotKeys  _hotKeys  = new Controller.HotKeys();
final Controller.Navigate _navigate = new Controller.Navigate();

/**
 * Commen methods for all view widgets.
 */
abstract class ViewWidget {
  /**
   * SHOULD return the widgets [Destination]. MAY return null if the widget has
   * no [Destination] associated with it.
   */
  Controller.Destination get _destination;

  /**
   * What to do when the widget blurs.
   */
  void _onBlur(Controller.Destination destination);

  /**
   * What to do when the widget is focused.
   */
  void _onFocus(Controller.Destination destination);

  /**
   * MUST return the widgets [UIModel].
   */
  Model.UIModel get _ui;

  /**
   * Navigate to [_destination] if widget is not already in focus.
   */
  void _navigateToMyDestination() {
    if(!_ui.isFocused) {
      _navigate.go(_destination);
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
  void _setWidgetState(Controller.Destination destination) {
    if(_destination == destination) {
      _ui.focus();
      _onFocus(destination);
    } else {
      _ui.blur();
      _onBlur(destination);
    }
  }
}
