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
import '../service/service.dart' as Service;

import '../dummies.dart';
import '../enums.dart';

import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart' as Markdown;
import 'package:okeyee/okeyee.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/bus.dart';
import 'package:openreception_framework/model.dart' as ORModel;

part 'model-app-state.dart';
part 'model-call.dart';
//part 'model-call-list.dart';
part 'model-client-connection-state.dart';
part 'model-contact.dart';
part 'model-contact-calendar.dart';
part 'model-calendar-entry.dart';
part 'model-message-endpoint.dart';
part 'model-phone-number.dart';
part 'model-reception.dart';
part 'model-reception-calendar.dart';
part 'model-user.dart';
part 'model-peer.dart';
part 'model-user-status.dart';

part 'model-ui-agent-info.dart';
part 'model-ui-calendar-editor.dart';
part 'model-ui-contact-calendar.dart';
part 'model-ui-contact-data.dart';
part 'model-ui-contact-selector.dart';
part 'model-ui-contexts.dart';
part 'model-ui-global-call-queue.dart';
part 'model-ui-hint.dart';
part 'model-ui-message-archive.dart';
part 'model-ui-message-archive-edit.dart';
part 'model-ui-message-archive-filter.dart';
part 'model-ui-message-compose.dart';
part 'model-ui-my-call-queue.dart';
part 'model-ui-reception-addresses.dart';
part 'model-ui-reception-alt-names.dart';
part 'model-ui-reception-bank-info.dart';
part 'model-ui-reception-calendar.dart';
part 'model-ui-reception-commands.dart';
part 'model-ui-reception-email.dart';
part 'model-ui-reception-mini-wiki.dart';
part 'model-ui-reception-opening-hours.dart';
part 'model-ui-reception-product.dart';
part 'model-ui-reception-salesmen.dart';
part 'model-ui-reception-selector.dart';
part 'model-ui-reception-telephone-numbers.dart';
part 'model-ui-reception-type.dart';
part 'model-ui-reception-vat-numbers.dart';
part 'model-ui-reception-websites.dart';
part 'model-ui-receptionistclient-ready.dart';
part 'model-ui-receptionistclient-disaster.dart';
part 'model-ui-receptionistclient-loading.dart';
part 'model-ui-welcome-message.dart';

const libraryName = 'model';

typedef selectCallback(LIElement li);

final Controller.HotKeys  _hotKeys  = new Controller.HotKeys();

/**
 * TODO (TL): Comment
 */
abstract class UIModel {
  final Keyboard _keyboard = new Keyboard();

  HtmlElement get _firstTabElement;
  HtmlElement get _focusElement;
  HtmlElement get _lastTabElement;
  HtmlElement get _root;

  /**
   * Blur the widget and set tabindex to -1.
   */
  void blur() {
    if(isFocused) {
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
    Map<String, EventListener> map = {'Shift+Tab': _handleShiftTab,
                                      'Tab'      : _handleTab};
    if(_listTarget != null) {
      map.addAll({'down': _handleUpDown,
                  'up'  : _handleUpDown});
    }

    if(myKeys != null) {
      map.addAll(myKeys);
    }

    return map;
  }

  /**
   * Focus the widget and set tabindex to 1.
   */
  void focus() {
    if(!isFocused) {
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
  bool get focusIsOnLast  => _focusElement == _lastTabElement;

  /**
   * Tab from first to last tab element when first is in focus an a Shift+Tab
   * event is caught.
   */
  void _handleShiftTab(KeyboardEvent event) {
    if(isFocused && focusIsOnFirst) {
      event.preventDefault();
      tabToLast();
    }
  }

  /**
   * Tab from last to first tab element when last is in focus an a Tab event
   * is caught.
   */
  void _handleTab(KeyboardEvent event) {
    if(isFocused && focusIsOnLast) {
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
    if(_listTarget.children.isNotEmpty) {
      final LIElement selected = _listTarget.querySelector('.selected');

      if(selected == null) {
        _markSelected(_scanForwardForVisibleElement(_listTarget.children.first));
        return;
      }

      switch(event.keyCode) {
        case KeyCode.DOWN:
          _markSelected(_scanForwardForVisibleElement(selected.nextElementSibling));
          break;
        case KeyCode.UP:
          _markSelected(_scanBackwardsForVisibleElement(selected.previousElementSibling));
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
  SpanElement get _headerExtra => _root.querySelector('h4 > span + span');

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
   * Mark [li] selected, scroll it into view and call [selectCallback].
   * Does nothing if [li] is null or [li] is already selected.
   */
  void _markSelected(LIElement li) {
    if(li != null && !li.classes.contains('selected')) {
      _listTarget.children.forEach((Element element) => element.classes.remove('selected'));
      li.classes.add('selected');
      li.scrollIntoView();
      _selectCallback(li);
    }
  }

  /**
   * Return the mouse click event stream for this widget.
   */
  Stream<MouseEvent> get onClick => _root.onClick;

  /**
   * Return the first [LIElement] that is not hidden. Search is forward,
   * starting with and including [li].
   */
  LIElement _scanForwardForVisibleElement(LIElement li) {
    if(li != null && li.classes.contains('hide')) {
      return _scanForwardForVisibleElement(li.nextElementSibling);
    } else {
      return li;
    }
  }

  /**
   * Return the first [LIElement] that is not hidden. Search is backwards,
   * starting with and including [li].
   */
  LIElement _scanBackwardsForVisibleElement(LIElement li) {
    if(li != null && li.classes.contains('hide')) {
      return _scanBackwardsForVisibleElement(li.previousElementSibling);
    } else {
      return li;
    }
  }

  /**
   * Is called by [_markSelected] whenever a [LIElement] is selected in the
   * [_listTarget] element.
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
