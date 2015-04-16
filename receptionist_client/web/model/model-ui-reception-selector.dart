part of model;

class UIReceptionSelector extends UIModel {
  Bus<Reception>   bus = new Bus<Reception>(); // TODO (TL): Make private
  final DivElement _myRoot;

  UIReceptionSelector(DivElement this._myRoot) {
    _registerEventListeners();
  }

  @override HtmlElement    get _firstTabElement => _filter;
  @override HtmlElement    get _focusElement    => _filter;
  @override HeadingElement get _header          => _root.querySelector('h4');
  @override DivElement     get _help            => _root.querySelector('div.help');
  @override HtmlElement    get _lastTabElement  => _filter;
  /**
   * Return the mousedown click event stream for this widget. We capture
   * mousedown instead of regular click to avoid the ugly focus/blur flicker
   * on the filter input whenever a reception li element is clicked.
   */
  @override Stream<MouseEvent> get onClick => _myRoot.onMouseDown;
  @override HtmlElement        get _root   => _myRoot;

  OListElement get _receptionList => _root.querySelector('.generic-widget-list');
  InputElement get _filter        => _root.querySelector('.filter');

  /**
   * Return true if the [event].target is the filter input field.
   */
  bool eventTargetIsFilterInput(MouseEvent event) {
    if(event.target == _filter) {
      return true;
    }

    return false;
  }

  /**
   * Filter the contact list whenever the user enters data into the [_filter]
   * input field.
   */
  void filter(_) {
    String filter = _filter.value.toLowerCase();
    String trimmedFilter = filter.trim();

    /// TODO (TL): This filtering model is a bit "meh". What we probably should
    /// do is leverage the CSS :not() selector and simply add/remove CSS rules
    /// based on the given filter values. That way we don't do any kind of
    /// looping, and all hiding/unhiding is left entirely to the browser.

    if(filter.length == 0 || trimmedFilter.isEmpty) {
      /// Empty filter. Remove .hide from all list elements.
      _receptionList.children.forEach((LIElement li) => li.classes.toggle('hide', false));
    } else if(trimmedFilter.length == 1) {
      _receptionList.children.forEach((LIElement li) {
        if(li.dataset['name'].startsWith(trimmedFilter)) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    } else {
      _receptionList.children.forEach((LIElement li) {
        if(li.dataset['name'].contains(trimmedFilter)) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    }
  }

  /**
   * Return the selected [Reception] from [_contactList]
   * MAY return null if nothing is selected.
   */
  Reception getSelectedReception() {
    try {
      return new Reception.fromElement(_receptionList.querySelector('.selected'));
    } catch (e) {
      print(e);
      return null;
    }
  }

  /**
   * Return the [Reception] the user clicked on.
   * MAY return null if the user did not click on an actual valid [Reception].
   */
  Reception getReceptionFromClick(MouseEvent event) {
    if(event.target is LIElement) {
      return new Reception.fromElement(event.target);
    }

    return null;
  }

  /**
   * Return the first visible [Reception] from [_receptionList]
   * MAY return null if the list is empty.
   */
  Reception getReceptionFirstVisible() {
    LIElement li = _receptionList.children.firstWhere((LIElement li) => !li.classes.contains('hide'), orElse: () => null);
    if(li != null) {
      return new Reception.fromElement(li);
    }

    return null;
  }

  /**
   * Return the last visible [Reception] from [_receptionList]
   * MAY return null if the list is empty.
   */
  Reception getReceptionLastVisible() {
    LIElement li = _receptionList.children.lastWhere((LIElement li) => !li.classes.contains('hide'), orElse: () => null);
    if(li != null) {
      return new Reception.fromElement(li);
    }

    return null;
  }

  /**
   * Mark [Reception] selected.
   */
  void markSelected(Reception reception) {
    if(reception != null) {
      _receptionList.children.forEach((Element element) => element.classes.remove('selected'));
      reception.li.classes.add('selected');
      reception.li.scrollIntoView();
    }
  }

  /**
   * Return the [Reception] following the currently selected [Reception].
   * Return null if we're at last element.
   */
  Reception nextReceptionInList() {
    LIElement selected = _receptionList.querySelector('.selected');

    if(selected == null) {
      return getReceptionFirstVisible();
    } else {
      LIElement li = _scanForwardForVisibleElement(selected);
      return li == null ? null : new Reception.fromElement(li);
    }
  }

  /**
   * Fires the selected [Reception].
   */
  Stream<Reception> get onSelect => bus.stream;

  /**
   * Return the [Reception] preceeding the currently selected [Reception].
   * Return null if we're at first element.
   */
  Reception previousReceptionInList() {
    LIElement selected = _receptionList.querySelector('.selected');

    if(selected == null) {
      return getReceptionLastVisible();
    } else {
      LIElement li = _scanBackwardsForVisibleElement(selected);
      return li == null ? null : new Reception.fromElement(li);
    }
  }

  /**
   * Add [items] to the receptions list.
   */
  set receptions(List<Reception> items) {
    items.forEach((Reception item) {
      item.li.dataset['name'] = item.name.toLowerCase();
      _receptionList.append(item.li);
    });
  }

  void _registerEventListeners() {
    _filter.onInput.listen(filter);

    /// These are here to prevent tab'ing out of the filter input.
    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);
  }

  /**
   * Remove selections, scroll to top and empty filter input.
   */
  void reset() {
    _filter.value = '';
    filter('');
    _receptionList.children.forEach((Element e) => e.classes.toggle('selected', false));
  }
}
