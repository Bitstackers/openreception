part of model;

class UIReceptionSelector extends UIModel {
  final Bus<Reception> _bus = new Bus<Reception>();
  final DivElement     _myRoot;

  /**
   * Constructor.
   */
  UIReceptionSelector(DivElement this._myRoot) {
    _observers();
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
   * Filter the contact list whenever the user enters data into the [_filter]
   * input field.
   */
  void filter(_) {
    final String filter = _filter.value.toLowerCase();
    final String trimmedFilter = filter.trim();

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
   * Deal with arrow up/down.
   */
  void _handleUpDown(KeyboardEvent event) {
    if(isFocused && _receptionList.children.isNotEmpty) {
      event.preventDefault();

      final LIElement selected = _receptionList.querySelector('.selected');

      /// Special case for this widget. If nothing is selected, simply select
      /// the first element in the list and return.
      if(selected == null) {
        _markSelected(_receptionList.children.first);
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
   * Mark [li] selected, scroll it into view and fire the [Contact] contained
   * in the [li] on the [onSelect] bus.
   * Does nothing if [li] is null or [li] is already selected.
   */
  void _markSelected(LIElement li) {
    if(isFocused && li != null && !li.classes.contains('selected')) {
      _receptionList.children.forEach((Element element) => element.classes.remove('selected'));
      li.classes.add('selected');
      li.scrollIntoView();
      _bus.fire(new Reception.fromJson(JSON.decode(li.dataset['object'])));
    }
  }

  /**
   * Observers
   */
  void _observers() {
    _filter.onInput.listen(filter);

    /// These are here to prevent tab'ing out of the filter input.
    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);

    _hotKeys.onDown.listen(_handleUpDown);
    _hotKeys.onUp  .listen(_handleUpDown);

    _hotKeys.onEnter.listen((_) => _markSelected(_scanForwardForVisibleElement(_receptionList.children.first)));
    _hotKeys.onEsc  .listen(reset);

    /// NOTE (TL): Don't switch this to _root.onClick. We need the mousedown
    /// event, not the mouseclick event. We want to keep focus on the filter at
    /// all times.
    onClick.listen(_selectFromClick);
  }

  /**
   * Fires the selected [Reception].
   */
  Stream<Reception> get onSelect => _bus.stream;

  /**
   * Add [items] to the receptions list.
   */
  set receptions(List<Reception> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((Reception item) {
      list.add(new LIElement()
                ..dataset['name'] = item.name.toLowerCase()
                ..dataset['object'] = JSON.encode(item)
                ..text = item.name);
    });

    _receptionList.children = list;
  }

  /**
   * Remove selections, scroll to top, empty filter input and fire a null
   * [Reception].
   */
  void reset(_) {
    if(isFocused) {
      _filter.value = '';
      filter('');
      _receptionList.children.forEach((Element e) => e.classes.toggle('selected', false));
      _bus.fire(new Reception.Null());
    }
  }

  /**
   * Mark a [LIElement] in the contact list selected, if one such is the target
   * of the [event].
   */
  void _selectFromClick(MouseEvent event) {
    if(event.target != _filter) {
      /// NOTE (TL): This keeps focus on the _filter field, despite clicks on
      /// other elements.
      event.preventDefault();

      if(event.target is LIElement) {
        _markSelected(event.target);
      }
    }
  }
}
