part of model;

/**
 * TODO (TL): Comment
 */
class UIContactData extends UIModel {
  final Bus<TelNum> _busRinging = new Bus<TelNum>();
  final DivElement  _myRoot;

  /**
   * Constructor.
   */
  UIContactData(DivElement this._myRoot) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _root;
  @override HtmlElement get _focusElement    => _root;
  @override HtmlElement get _lastTabElement  => _root;
  @override HtmlElement get _root            => _myRoot;

  OListElement   get _additionalInfoList => _root.querySelector('.additional-info');
  OListElement   get _backupsList        => _root.querySelector('.backups');
  OListElement   get _commandsList       => _root.querySelector('.commands');
  OListElement   get _departmentList     => _root.querySelector('.department');
  OListElement   get _emailAddressesList => _root.querySelector('.email-addresses');
  OListElement   get _relationsList      => _root.querySelector('.relations');
  OListElement   get _responsibilityList => _root.querySelector('.responsibility');
  OListElement   get _telNumList         => _root.querySelector('.telephone-number');
  OListElement   get _titleList          => _root.querySelector('.title');
  OListElement   get _workHoursList      => _root.querySelector('.work-hours');

  /**
   * Add [items] to the additional info list.
   */
  set additionalInfo(List<String> items) => _populateList(_additionalInfoList, items);

  /**
   * Add [items] to the backups list.
   */
  set backups(List<String> items) => _populateList(_backupsList, items);

  /**
   * Remove all data from the widget.
   */
  void clear() {
    _headerExtra.text = '';
    _additionalInfoList.children.clear();
    _backupsList.children.clear();
    _commandsList.children.clear();
    _departmentList.children.clear();
    _emailAddressesList.children.clear();
    _relationsList.children.clear();
    _responsibilityList.children.clear();
    _telNumList.children.clear();
    _titleList.children.clear();
    _workHoursList.children.clear();
  }

  /**
   * Returns the mousedown click stream for the telephone numbers list.
   */
  Stream<MouseEvent> get clickSelectTelNum => _telNumList.onMouseDown;

  /**
   * Add [items] ot the commands list.
   */
  set commands(List<String> items) => _populateList(_commandsList, items);

  /**
   * Add [items] to the departments list.
   */
  set departments(List<String> items) => _populateList(_departmentList, items);

  /**
   * Add [items] to the email addresses list.
   */
  set emailAddresses(List<String> items) => _populateList(_emailAddressesList, items);

  /**
   * Deal with arrow up/down.
   */
  void _handleUpDown(KeyboardEvent event) {
    if(_telNumList.children.isNotEmpty) {
      final LIElement selected = _telNumList.querySelector('.selected');

      /// TODO (TL): Handle selected == null.

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
   * Mark [li] ringing, scroll it into view.
   * Does nothing if [li] is null or [li] is already ringing.
   */
  void _markRinging(LIElement li) {
    if(li != null && !li.classes.contains('ringing')) {
      _telNumList.children.forEach((Element element) => element.classes.remove('ringing'));
      li.classes.add('ringing');
      li.scrollIntoView();
    }
  }

  /**
   * Mark [li] selected, scroll it into view.
   * Does nothing if [li] is null or [li] is already selected.
   */
  void _markSelected(LIElement li) {
    if(li != null && !li.classes.contains('selected')) {
      _telNumList.children.forEach((Element element) => element.classes.remove('selected'));
      li.classes.add('selected');
      li.scrollIntoView();
    }
  }

  /**
   * Return true if no telNumList items are marked "ringing".
   */
  bool get noRinging => !_telNumList.children.any((e) => e.classes.contains('ringing'));

  /**
   * Observers
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen(_selectFromClick);

    ///
    ///
    ///
    /// TODO (TL): Listen for call notifications here? Possibly mark ringing?
    /// Or put this in view-contact-data.dart?
    ///
    ///
    ///
    ///
  }

  /**
   * Fires when a [TelNum] is marked ringing.
   */
  Stream<TelNum> get onMarkedRinging => _busRinging.stream;

  /**
   * TODO (TL): Comment
   */
  void _populateList(OListElement parent, List<String> list) {
    list.forEach((String item) {
      parent.append(new LIElement()..text = item);
    });
  }

  /**
   * Add [items] to the relations list.
   */
  set relations(List<String> items) => _populateList(_relationsList, items);

  /**
   * Add [items] to the responsibility list.
   */
  set responsibility(List<String> items) => _populateList(_responsibilityList, items);

  /**
   * Mark selected [TelNum] ringing if we're not already ringing.
   */
  void _ring(_) {
    LIElement li = _telNumList.querySelector('.selected');

    if(li != null) {
      if(!_telNumList.children.any((LIElement li) => li.classes.contains('ringing'))) {
        li.classes.toggle('ringing');
        _busRinging.fire(new TelNum.fromJson(JSON.decode(li.dataset['object'])));
      }
    }
  }

  /**
   * Select the first [TelNum] in the list.
   */
  void selectFirstTelNum() {
    if(_telNumList.children.isNotEmpty) {
      _markSelected(_scanForwardForVisibleElement(_telNumList.children.first));
    }
  }

  /**
   * Select the [index] [TelNum] from [_telNumList]. If [index] is out of range,
   * select nothing.
   */
  void selectFromIndex(int index) {
    if(_telNumList.children.length >= index) {
      _markSelected(_scanForwardForVisibleElement(_telNumList.children[index]));
    }
  }

  /**
   * Mark a [LIElement] in the event list selected, if one such is the target
   * of the [event].
   */
  void _selectFromClick(MouseEvent event) {
    if(event.target is LIElement || (event.target is SpanElement)) {
      LIElement clickedElement =
          (event.target is SpanElement) ? (event.target as Element).parentNode : event.target;
      _markSelected(clickedElement);
    }
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    final Map<String, EventListener> bindings =
        {[Key.NumMult]: _ring,
         'Alt+1'      : (_) => selectFirstTelNum(),
         'Alt+2'      : (_) => selectFromIndex(1),
         'Alt+3'      : (_) => selectFromIndex(2),
         'Alt+4'      : (_) => selectFromIndex(3),
         'down'       : _handleUpDown,
         'Shift+Tab'  : _handleShiftTab,
         'Tab'        : _handleTab,
         'up'         : _handleUpDown};

    _hotKeys.registerKeysPreventDefault(_keyboard, bindings);
  }

  /**
   * Add [items] to the telephone number list.
   */
  set telephoneNumbers(List<TelNum> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((TelNum item) {
      final SpanElement spanLabel  = new SpanElement();
      final SpanElement spanNumber = new SpanElement();

      spanNumber.classes.toggle('secret', item.secret);
      spanNumber.classes.add('number');
      spanNumber.text = item.number;

      spanLabel.classes.add('label');
      spanLabel.text = item.label;


      list.add(new LIElement()
                ..children.addAll([spanNumber, spanLabel])
                ..dataset['id'] = item.id.toString()
                ..dataset['object'] = JSON.encode(item));
    });

    _telNumList.children = list;
  }

  /**
   * Add [items] to the titles list.
   */
  set titles(List<String> items) => _populateList(_titleList, items);

  /**
   * Add [items] to the workhours list.
   */
  set workHours(List<String> items) => _populateList(_workHoursList, items);
}
