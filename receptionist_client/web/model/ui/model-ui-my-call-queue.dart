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
 * Provides access to the my call queue widget.
 */
class UIMyCallQueue extends UIModel {
  final Controller.Contact _contactController;
  final Map<int, String> _contactMap = new Map<int, String>();
  final Map<String, String> _langMap;
  final DivElement _myRoot;
  final Controller.Reception _receptionController;
  final Map<int, String> _receptionMap = new Map<int, String>();

  /**
   * Constructor.
   */
  UIMyCallQueue(DivElement this._myRoot, Map<String, String> this._langMap,
      Controller.Contact this._contactController, Controller.Reception this._receptionController) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _list;
  @override HtmlElement get _focusElement => _list;
  @override HtmlElement get _lastTabElement => _list;
  @override HtmlElement get _root => _myRoot;

  SpanElement get _queueLength => _root.querySelector('.generic-widget-headline span.queue-length');
  OListElement get _list => _root.querySelector('.generic-widget-list');

  /**
   * Append [call] to the calls list.
   */
  appendCall(ORModel.Call call) {
    _list.children.add(_buildCallElement(call));
    _queueLengthUpdate();
  }

  /**
   * Construct a call [LIElement] from [call]
   */
  LIElement _buildCallElement(ORModel.Call call) {
    final DivElement numbersAndStateDiv = new DivElement();
    final DivElement nameDiv = new DivElement();

    setName(call, nameDiv);

    final SpanElement callState = new SpanElement()
      ..classes.add('call-state')
      ..text = _langMap['callstate-${call.state.toLowerCase()}'];

    final SpanElement callDesc = new SpanElement()
      ..classes.add('call-description')
      ..text = call.inbound ? '${call.callerID}' : '${call.destination}'
      ..children.add(callState);

    final SpanElement callWaitTimer = new SpanElement()
      ..classes.add('call-wait-time')
      ..text = new DateTime.now().difference(call.arrived).inSeconds.toString();

    numbersAndStateDiv.children.addAll([callDesc, callWaitTimer]);

    return (new LIElement()
      ..dataset['id'] = call.ID
      ..dataset['object'] = JSON.encode(call)
      ..children.addAll([numbersAndStateDiv, nameDiv])
      ..classes.add(call.inbound ? 'inbound' : 'outbound')
      ..classes.toggle('locked', call.locked)
      ..classes.toggle('speaking', call.state == ORModel.CallState.Speaking)
      ..title =
          '${call.inbound ? _langMap[Key.callStateInbound] : _langMap[Key.callStateOutbound]}');
  }

  /**
   * Read all .call-wait-time values in _list and increment them by one.
   */
  void _callAgeUpdate() {
    new Timer.periodic(new Duration(seconds: 1), (_) {
      _list.querySelectorAll('li span.call-wait-time').forEach((SpanElement span) {
        if (span.text.isEmpty) {
          span.text = '0';
        } else {
          span.text = (int.parse(span.text) + 1).toString();
        }
      });
    });
  }

  /**
   * Return the list of calls found in my call queue.
   */
  List<ORModel.Call> get calls => _list
      .querySelectorAll('li')
      .map((LIElement li) => new ORModel.Call.fromMap(JSON.decode(li.dataset['object'])))
      .toList();

  /**
   * Add [calls] to the calls list.
   */
  set calls(List<ORModel.Call> calls) {
    final List<LIElement> list = new List<LIElement>();

    calls.forEach((ORModel.Call call) {
      list.add(_buildCallElement(call));
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
   * Add [contact] to the local cache of contact names.
   *
   * This is used to quickly associate outbound calls with a contact.
   */
  set contact(ORModel.Contact contact) {
    _contactMap[contact.ID] = contact.fullName;
  }

  /**
   * Mark [call] ready for transfer.
   */
  void markForTransfer(ORModel.Call call) {
    print('markForTransfer: ${call.inbound ? 'in' : 'out'} - ${call.ID}');
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
   * Add [reception] to the local cache of reception names.
   *
   * This is used to quickly associate inbound calls with a reception.
   */
  set reception(ORModel.Reception reception) {
    _receptionMap[reception.ID] = reception.name;
  }

  /**
   * Remove [call] from the call list. Does nothing if [call] does not exist
   * in the call list.
   */
  void removeCall(ORModel.Call call) {
    final LIElement li = _list.querySelector('[data-id="${call.ID}"]');

    if (li != null) {
      li.remove();
      _queueLengthUpdate();
    }
  }

  /**
   * Adds a contact or reception name to [nameDiv].
   *
   * If a name cannot be found in either [_contactMap] or [_receptionMap], then we will fetch a name
   * from the server asynchronously and cache it locally.
   */
  void setName(ORModel.Call call, DivElement nameDiv) {
    if (call.inbound) {
      if (_receptionMap.containsKey(call.receptionID)) {
        nameDiv.text = _receptionMap[call.receptionID];
      } else {
        _receptionController.get(call.receptionID).then((ORModel.Reception reception) {
          nameDiv.text = reception.fullName;
          _receptionMap[call.receptionID] = reception.fullName;
        });
      }
    } else {
      if (_contactMap.containsKey(call.contactID)) {
        nameDiv.text = _contactMap[call.contactID];
      } else {
        _contactController.get(call.contactID).then((ORModel.BaseContact contact) {
          nameDiv.text = contact.fullName;
          _contactMap[call.contactID] = contact.fullName;
        });
      }
    }
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap());
  }

  /**
   * Update [call] in the call list. If [call] does not exist in the call list, it is appended to
   * the list.
   */
  void updateCall(ORModel.Call call) {
    final LIElement li = _list.querySelector('[data-id="${call.ID}"]');

    if (li != null) {
      li.replaceWith(_buildCallElement(call));
    } else {
      appendCall(call);
    }
  }
}
