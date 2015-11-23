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
 * Provides methods to manipulate and extract data from the widget UX parts.
 */
class UIReceptionSelector extends UIModel {
  final Bus<ORModel.Reception> _bus = new Bus<ORModel.Reception>();
  final DivElement _myRoot;
  final Bus<ORModel.Reception> _selectedRemovedBus = new Bus<ORModel.Reception>();
  final Bus<ORModel.Reception> _selectedUpdatedBus = new Bus<ORModel.Reception>();

  /**
   * Constructor.
   */
  UIReceptionSelector(DivElement this._myRoot) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _filter;
  @override HtmlElement get _focusElement => _filter;
  @override HtmlElement get _lastTabElement => _filter;
  @override HtmlElement get _listTarget => _list;
  /**
   * Return the mousedown click event stream for this widget. We capture
   * mousedown instead of regular click to avoid the ugly focus/blur flicker
   * on the filter input whenever a reception li element is clicked.
   */
  @override Stream<MouseEvent> get onClick => _myRoot.onMouseDown;
  @override selectCallback get _selectCallback => _receptionSelectCallback;
  @override HtmlElement get _root => _myRoot;

  OListElement get _list => _root.querySelector('.generic-widget-list');
  InputElement get _filter => _root.querySelector('.filter');

  /**
   * Add [reception] to the reception list, sorted alphabetically by reception
   * name.
   * If [selected] is true, then mark the [reception] selected, but do not fire
   * the reception anew. If [selected] is false, then search for the currently
   * selected reception, and make sure it is scrolled into view.
   */
  void addReception(ORModel.Reception reception, {bool selected: false}) {
    LIElement newLi = new LIElement()
      ..dataset['id'] = reception.ID.toString()
      ..dataset['name'] = reception.name.toLowerCase()
      ..dataset['object'] = JSON.encode(reception)
      ..text = reception.name;

    LIElement firstBiggerName = _list.querySelectorAll('li').firstWhere(
        (Element element) => newLi.dataset['name'].compareTo(element.dataset['name']) < 0,
        orElse: () => null);

    if (firstBiggerName == null) {
      _list.append(newLi);
    } else {
      _list.insertBefore(newLi, firstBiggerName);
    }

    if (selected) {
      _markSelected(newLi, callSelectCallback: false);
    } else {
      LIElement selectedLi = _list.querySelector('.selected');
      if (selectedLi != null) {
        selectedLi.scrollIntoView();
      }
    }
  }

  /**
   * Mark the [receptionId] list item as selected.
   */
  void changeActiveReception(int receptionId) {
    _markSelected(_list.querySelector('[data-id="$receptionId"]'));
  }

  /**
   * Filter the reception list whenever the user enters data into the [_filter]
   * input field.
   */
  void _filterList(_) {
    final String filter = _filter.value.toLowerCase();
    final String trimmedFilter = filter.trim();

    if (filter.length == 0 || trimmedFilter.isEmpty) {
      /// Empty filter. Remove .hide from all list elements.
      _list.children.forEach((LIElement li) => li.classes.toggle('hide', false));
      _list.classes.toggle('zebra', true);
    } else if (trimmedFilter.length == 1) {
      _list.classes.toggle('zebra', false);

      _list.children.forEach((LIElement li) {
        if (li.dataset['name'].startsWith(trimmedFilter)) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    } else {
      _list.classes.toggle('zebra', false);

      _list.children.forEach((LIElement li) {
        if (li.dataset['name'].contains(trimmedFilter)) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    }
  }

  /**
   * Deal with enter.
   */
  void _handleEnter(KeyboardEvent event) {
    if (_filter.value.trim().isNotEmpty) {
      _markSelected(_scanForwardForVisibleElement(_list.children.first));
    }
  }

  /**
   * Observers
   */
  void _observers() {
    _filter.onKeyDown.listen(_keyboard.press);

    _filter.onInput.listen(_filterList);

    /// NOTE (TL): Don't switch this to _root.onClick. We need the mousedown
    /// event, not the mouseclick event. We want to keep focus on the filter at
    /// all times.
    onClick.listen(_selectFromClick);
  }

  /**
   * Fires the selected [Reception].
   */
  Stream<ORModel.Reception> get onSelect => _bus.stream;

  /**
   * Fires when the selected reception is removed.
   */
  Stream<ORModel.Reception> get onSelectedRemoved => _selectedRemovedBus.stream;

  /**
   * Fires when the selected reception is updated.
   */
  Stream<ORModel.Reception> get onSelectedUpdated => _selectedUpdatedBus.stream;

  /**
   * Add [items] to the receptions list.
   */
  set receptions(List<ORModel.Reception> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((ORModel.Reception item) {
      list.add(new LIElement()
        ..dataset['id'] = item.ID.toString()
        ..dataset['name'] = item.name.toLowerCase()
        ..dataset['object'] = JSON.encode(item)
        ..text = item.name);
    });

    _list.children = list;
  }

  /**
   * Fire a [Reception] on [_bus]. The [Reception] is constructed from JSON found
   * in the data-object attribute of [li].
   */
  void _receptionSelectCallback(LIElement li) {
    _bus.fire(new ORModel.Reception.fromMap(JSON.decode(li.dataset['object'])));
  }

  /**
   * Remove [reception] from the reception selector.
   */
  void removeReception(ORModel.Reception reception, {bool fire: true}) {
    LIElement newLi = _list.querySelector('[data-id="${reception.ID.toString()}"]');

    if (newLi != null) {
      ORModel.Reception selected = selectedReception;
      newLi.remove();
      if (fire && reception.ID == selected.ID) {
        _selectedRemovedBus.fire(selected);
      }
    }
  }

  /**
   * Remove selections, scroll to top, empty filter input and fire a null
   * [Reception].
   */
  void reset() => _reset(null);
  void _reset(_) {
    _filter.value = '';
    _filterList('');
    _list.children.forEach((Element e) => e.classes.toggle('selected', false));
    _bus.fire(new ORModel.Reception.empty());
  }

  /**
   * Mark a [LIElement] in the reception list selected, if one such is the target
   * of the [event].
   */
  void _selectFromClick(MouseEvent event) {
    if (event.target != _filter) {
      /// NOTE (TL): This keeps focus on the _filter field, despite clicks on
      /// other elements.
      event.preventDefault();

      if (event.target is LIElement) {
        _markSelected(event.target);
      }
    }
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    final Map<String, EventListener> bindings = {'Enter': _handleEnter, 'Esc': _reset};

    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap(myKeys: bindings));
  }

  /**
   * Returns the currently selected [Reception].
   *
   * Return [Reception.none] if no [Reception] is selected.
   */
  ORModel.Reception get selectedReception {
    LIElement li = _list.querySelector('.selected');

    if (li != null) {
      return new ORModel.Reception.fromMap(JSON.decode(li.dataset['object']));
    } else {
      return new ORModel.Reception.empty();
    }
  }

  /**
   * If [reception] exists in the reception selector list, then update it.
   */
  void updateReception(ORModel.Reception reception) {
    bool selected = selectedReception.ID == reception.ID;
    removeReception(reception, fire: false);
    addReception(reception, selected: selected);

    if (selected) {
      _selectedUpdatedBus.fire(reception);
    }
  }
}
