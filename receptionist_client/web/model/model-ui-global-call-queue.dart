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

part of model;

/**
 * TODO (TL): Comment
 */
class UIGlobalCallQueue extends UIModel {
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIGlobalCallQueue(DivElement this._myRoot) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _list;
  @override HtmlElement get _focusElement    => _list;
  @override HtmlElement get _lastTabElement  => _list;
  @override HtmlElement get _root            => _myRoot;

  SpanElement  get _queueLength => _root.querySelector('.generic-widget-headline span.queue-length');
  OListElement get _list        => _root.querySelector('.generic-widget-list');

  /**
   * Read all .call-wait-time values in _list and increment them by one.
   */
  void _callAgeUpdate() {
    new Timer.periodic(new Duration(seconds: 1), (_) {
      _list.querySelectorAll('li span.call-wait-time').forEach((SpanElement span) {
        if(span.text.isEmpty) {
          span.text = '0';
        } else {
          span.text = (int.parse(span.text) + 1).toString();
        }
      });
    });
  }

  /**
   * Add [calls] to the calls list.
   */
  set calls(List<ORModel.Call> calls) {
    final List<LIElement> list = new List<LIElement>();

    calls.forEach((ORModel.Call call) {
      SpanElement callDesc = new SpanElement()
                                  ..classes.add('call-description')
                                  ..text = call.callerID;
      /// TODO (TL): When we get VIP, add class flag-vip to callDesc on VIP calls.

      SpanElement callWait = new SpanElement()
                                  ..classes.add('call-wait-time')
                                  ..text = new DateTime.now().difference(call.arrived).inSeconds.toString();

      list.add(new LIElement()
                    ..dataset['id'] = call.ID
                    ..dataset['object'] = JSON.encode(call)
                    ..children.addAll([callDesc, callWait])
                    ..classes.toggle('locked', call.locked));
    });

    _list.children = list;

    _queueLengthUpdate();
  }

  /**
   * Remove all entries from the list and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _list.children.clear();
  }

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen((_) => _list.focus());

    _callAgeUpdate();
  }

  /**
   * Update the queue length counter in the widget.
   */
  void _queueLengthUpdate() {
    _queueLength.text = _list.querySelectorAll('li').length.toString();
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap());
  }
}
