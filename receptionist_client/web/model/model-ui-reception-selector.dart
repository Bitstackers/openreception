part of model;

/**
 * TODO (TL): Comment
 */
class UIReceptionSelector extends UIModel {
  final Bus<Reception> _bus = new Bus<Reception>();
  final DivElement     _myRoot;

  /**
   * Constructor.
   */
  UIReceptionSelector(DivElement this._myRoot) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _arrowTarget     => _list;
  @override HtmlElement get _firstTabElement => _filter;
  @override HtmlElement get _focusElement    => _filter;
  @override HtmlElement get _lastTabElement  => _filter;
  /**
   * Return the mousedown click event stream for this widget. We capture
   * mousedown instead of regular click to avoid the ugly focus/blur flicker
   * on the filter input whenever a reception li element is clicked.
   */
  @override Stream<MouseEvent> get onClick         => _myRoot.onMouseDown;
  @override selectCallback     get _selectCallback => _arrowSelectCallback;
  @override HtmlElement        get _root           => _myRoot;

  OListElement get _list   => _root.querySelector('.generic-widget-list');
  InputElement get _filter => _root.querySelector('.filter');

  /**
   * TODO (TL): Comment
   */
  void _arrowSelectCallback(LIElement li) {
    _bus.fire(new Reception.fromMap(JSON.decode(li.dataset['object'])));
  }

  /**
   * Filter the reception list whenever the user enters data into the [_filter]
   * input field.
   */
  void filter(_) {
    final String filter = _filter.value.toLowerCase();
    final String trimmedFilter = filter.trim();

    if(filter.length == 0 || trimmedFilter.isEmpty) {
      /// Empty filter. Remove .hide from all list elements.
      _list.children.forEach((LIElement li) => li.classes.toggle('hide', false));
      _list.classes.toggle('zebra', true);
    } else if(trimmedFilter.length == 1) {
      _list.classes.toggle('zebra', false);

      _list.children.forEach((LIElement li) {
        if(li.dataset['name'].startsWith(trimmedFilter)) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    } else {
      _list.classes.toggle('zebra', false);

      _list.children.forEach((LIElement li) {
        if(li.dataset['name'].contains(trimmedFilter)) {
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
    _markSelected(_scanForwardForVisibleElement(_list.children.first));
  }

  /**
   * Observers
   */
  void _observers() {
    _filter.onKeyDown.listen(_keyboard.press);

    _filter.onInput.listen(filter);

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

    _list.children = list;
  }

  /**
   * Remove selections, scroll to top, empty filter input and fire a null
   * [Reception].
   */
  void _reset(_) {
    _filter.value = '';
    filter('');
    _list.children.forEach((Element e) => e.classes.toggle('selected', false));
    _bus.fire(new Reception.none());
  }

  /**
   * Mark a [LIElement] in the reception list selected, if one such is the target
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

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    final Map<String, EventListener> bindings =
        {'Enter': _handleEnter,
         'Esc'  : _reset};

    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap(myKeys: bindings));
  }
}
