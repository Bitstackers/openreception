library model;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'dummies.dart';

import '../controller/controller.dart';

part 'model-ui-agent-info.dart';
part 'model-ui-calendar-editor.dart';
part 'model-ui-contact-calendar.dart';
part 'model-ui-contact-data.dart';
part 'model-ui-contact-selector.dart';
part 'model-ui-contexts.dart';
part 'model-ui-help.dart';
part 'model-ui-message-compose.dart';
part 'model-ui-reception-calendar.dart';
part 'model-ui-reception-commands.dart';
part 'model-ui-reception-selector.dart';
part 'model-ui-receptionistclient-ready.dart';
part 'model-ui-receptionistclient-disaster.dart';
part 'model-ui-receptionistclient-loading.dart';

final HotKeys  _hotKeys  = new HotKeys();

abstract class UIModel {
  HtmlElement    get _firstTabElement;
  HtmlElement    get _focusElement;
  HeadingElement get _header;
  DivElement     get _help;
  HtmlElement    get _lastTabElement;
  HtmlElement    get _root;

  /**
   * Return true if the widget is in focus.
   */
  bool get active => _root.classes.contains('focus');

  /**
   * Blur the widget and set tabindex to -1.
   */
  void blur() {
    if(active) {
      _root.classes.toggle('focus', false);
      _focusElement.blur();
      _setTabIndex(-1);
    }
  }

  /**
   * Focus the widget and set tabindex to 1.
   */
  void focus() {
    if(!active) {
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
    if(active && focusIsOnFirst) {
      event.preventDefault();
      tabToLast();
    }
  }

  /**
   * Tab from last to first tab element when last is in focus an a Tab event
   * is caught.
   */
  void _handleTab(KeyboardEvent event) {
    if(active && focusIsOnLast) {
      event.preventDefault();
      tabToFirst();
    }
  }

  /**
   * Set the widget header.
   */
  set header(String headline) => _header.text = headline;

  /**
   * Set the help text.
   *
   * TODO (TL): Do some placing/sizing magic, so the help box is always centered,
   * no matter the length of the help text.
   */
  set help(String help) => _help.text = help;

  /**
   * Return the mouse click event stream for this widget.
   */
  Stream<MouseEvent> get onClick => _root.onClick;

  /**
   * Find the first proceeding sibling that is not hidden.
   */
  LIElement _scanAheadForVisibleSibling(LIElement li) {
    LIElement next = li.nextElementSibling;

    if(next != null && next.classes.contains('hide')) {
      return _scanAheadForVisibleSibling(next);
    } else {
      return next;
    }
  }

  /**
   * Find the first preceeding sibling that is not hidden.
   */
  LIElement _scanBackForVisibleSibling(LIElement li) {
    LIElement previous = li.previousElementSibling;

    if(previous != null && previous.classes.contains('hide')) {
      return _scanBackForVisibleSibling(previous);
    } else {
      return previous;
    }
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
