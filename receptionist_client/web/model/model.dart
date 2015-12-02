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

library model;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../controller/controller.dart' as Controller;
import '../lang.dart';

import 'package:markdown/markdown.dart' as Markdown;
import 'package:okeyee/okeyee.dart' as Okeyee;
import 'package:logging/logging.dart';
import 'package:openreception_framework/bus.dart';
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:openreception_framework/util.dart' as ORUtil;

part 'model-app-state.dart';
part 'model-client-connection-state.dart';

part 'ui/model-ui-agent-info.dart';
part 'ui/model-ui-calendar-editor.dart';
part 'ui/model-ui-contact-calendar.dart';
part 'ui/model-ui-contact-data.dart';
part 'ui/model-ui-contact-selector.dart';
part 'ui/model-ui-contexts.dart';
part 'ui/model-ui-global-call-queue.dart';
part 'ui/model-ui-hint.dart';
part 'ui/model-ui-message-archive.dart';
part 'ui/model-ui-message-compose.dart';
part 'ui/model-ui-my-call-queue.dart';
part 'ui/model-ui-orc-ready.dart';
part 'ui/model-ui-reception-addresses.dart';
part 'ui/model-ui-reception-alt-names.dart';
part 'ui/model-ui-reception-bank-info.dart';
part 'ui/model-ui-reception-calendar.dart';
part 'ui/model-ui-reception-commands.dart';
part 'ui/model-ui-reception-email.dart';
part 'ui/model-ui-reception-mini-wiki.dart';
part 'ui/model-ui-reception-opening-hours.dart';
part 'ui/model-ui-reception-product.dart';
part 'ui/model-ui-reception-salesmen.dart';
part 'ui/model-ui-reception-selector.dart';
part 'ui/model-ui-reception-telephone-numbers.dart';
part 'ui/model-ui-reception-type.dart';
part 'ui/model-ui-reception-vat-numbers.dart';
part 'ui/model-ui-reception-websites.dart';
part 'ui/model-ui-receptionistclient-disaster.dart';
part 'ui/model-ui-receptionistclient-loading.dart';
part 'ui/model-ui-welcome-message.dart';

const libraryName = 'model';

typedef String HumanReadableTimestamp(DateTime timestamp, Map<int, String> dayMap);
typedef void selectCallback(LIElement li);

final Controller.HotKeys _hotKeys = new Controller.HotKeys();

/**
 * Base class for all UI model classes.
 */
abstract class UIModel {
  final Okeyee.Keyboard _keyboard = new Okeyee.Keyboard();

  HtmlElement get _firstTabElement;
  HtmlElement get _focusElement;
  HtmlElement get _lastTabElement;
  HtmlElement get _root;

  /**
   * Blur the widget and set tabindex to -1.
   */
  void blur() {
    if (isFocused) {
      _root.classes.toggle('focus', false);
      _focusElement.blur();
      _setTabIndex(-1);
    }
  }

  /**
   * The map returned from this method ALWAYS contains "Tab" and "Shift+Tab".
   * These two maps to [_handleTab] and [_handleShiftTab] respectively.
   *
   * It MAY contain "down" and "up", if [_listTarget] is not null. These two
   * are mapped to [_handleUpDown].
   */
  Map<String, EventListener> _defaultKeyMap({Map<String, EventListener> myKeys}) {
    Map<String, EventListener> map = {'Shift+Tab': _handleShiftTab, 'Tab': _handleTab};
    if (_listTarget != null) {
      map.addAll({'down': _handleUpDown, 'up': _handleUpDown});
    }

    if (myKeys != null) {
      map.addAll(myKeys);
    }

    return map;
  }

  /**
   * Focus the widget and set tabindex to 1.
   */
  void focus() {
    if (!isFocused) {
      _setTabIndex(1);
      _root.classes.toggle('focus', true);
      _focusElement.focus();
    }
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
  bool get focusIsOnLast => _focusElement == _lastTabElement;

  /**
   * Tab from first to last tab element when first is in focus an a Shift+Tab
   * event is caught.
   */
  void _handleShiftTab(KeyboardEvent event) {
    if (isFocused && focusIsOnFirst) {
      event.preventDefault();
      tabToLast();
    }
  }

  /**
   * Tab from last to first tab element when last is in focus an a Tab event
   * is caught.
   */
  void _handleTab(KeyboardEvent event) {
    if (isFocused && focusIsOnLast) {
      event.preventDefault();
      tabToFirst();
    }
  }

  /**
   * This method can be used to handle up/down arrow events with [_listTarget]
   * as the target list. If [_listTarget] is not empty, then scan forward
   * for "down" arrow and backwards for "up" arrow. Call [_markSelected] on the
   * first element found that is visible and not selected.
   */
  void _handleUpDown(KeyboardEvent event) {
    if (_listTarget.children.isNotEmpty) {
      final LIElement selected = _listTarget.querySelector('.selected');

      if (selected == null) {
        _markSelected(_scanForwardForVisibleElement(_listTarget.children.first));
        return;
      }

      switch (event.keyCode) {
        case KeyCode.DOWN:
          _markSelected(_scanForwardForVisibleElement(selected.nextElementSibling));
          break;
        case KeyCode.UP:
          _markSelected(_scanBackwardForVisibleElement(selected.previousElementSibling));
          break;
      }
    }
  }

  /**
   * Return the header element.
   */
  SpanElement get _header => _root.querySelector('h4 > span');

  /**
   * Set the widget header.
   */
  set header(String headline) => _header.text = headline;

  /**
   * Return the headerExtra element.
   */
  SpanElement get _headerExtra => _root.querySelector('h4 span.extra-header');

  /**
   * Set the widgets extra header. This one can be used for a bit of extra data
   * to decorate the widget.
   */
  set headerExtra(String headlineExtra) => _headerExtra.text = headlineExtra;

  /**
   * Return the hint element.
   */
  DivElement get _hint => _root.querySelector('div.hint');

  /**
   * Return true if the widget is in focus.
   */
  bool get isFocused => _root.classes.contains('focus');

  /**
   * MUST return a [HtmlElement] that contains [LIElement]'s. This is used by
   * other methods as the parent for selectable elements, normally a list of
   * items that can be clicked on and/or chosen by "up" / "down" keyboard events.
   */
  HtmlElement get _listTarget => null;

  /**
   * Mark [li] selected, scroll it into view andif [callSelectCallback] is true
   * then call [selectCallback].
   * Does nothing if [li] is null or [li] is already selected.
   */
  void _markSelected(LIElement li, {bool callSelectCallback: true}) {
    if (li != null && !li.classes.contains('selected')) {
      _listTarget.children.forEach((Element element) => element.classes.remove('selected'));
      li.classes.add('selected');
      li.scrollIntoView();
      if (callSelectCallback) {
        _selectCallback(li);
      }
    }
  }

  /**
   * Return the mouse click event stream for this widget.
   */
  Stream<MouseEvent> get onClick => _root.onClick;

  /**
   * Return the first [LIElement] that is not hidden. Search is forward starting with and including
   * [li].
   */
  LIElement _scanForwardForVisibleElement(LIElement li) {
    if (li != null && li.classes.contains('hide')) {
      return _scanForwardForVisibleElement(li.nextElementSibling);
    } else {
      return li;
    }
  }

  /**
   * Return the first [LIElement] that is not hidden. Search is backwards, starting with and
   * including [li].
   */
  LIElement _scanBackwardForVisibleElement(LIElement li) {
    if (li != null && li.classes.contains('hide')) {
      return _scanBackwardForVisibleElement(li.previousElementSibling);
    } else {
      return li;
    }
  }

  /**
   * Is called by [_markSelected] whenever a [LIElement] is selected in the [_listTarget] element.
   */
  selectCallback get _selectCallback => (LIElement li) => null;

  /**
   * Set hint text
   */
  void setHint(String hint) {
    _hint.text = hint;
  }

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
