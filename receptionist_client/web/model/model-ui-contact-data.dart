part of model;

class UIContactData extends UIModel {
  final DivElement _myRoot;

  UIContactData(DivElement this._myRoot);

  @override HtmlElement    get _firstTabElement => null;
  @override HtmlElement    get _focusElement    => _telNumList;
  @override HeadingElement get _header          => _root.querySelector('h4');
  @override DivElement     get _help            => _root.querySelector('div.help');
  @override HtmlElement    get _lastTabElement  => null;
  @override HtmlElement    get _root            => _myRoot;

  OListElement   get _additionalInfoList => _root.querySelector('.additional-info');
  OListElement   get _backupsList        => _root.querySelector('.backups');
  OListElement   get _commandsList       => _root.querySelector('.commands');
  SpanElement    get _headerContactName  => _root.querySelector('h4 span');
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
    _additionalInfoList.children.clear();
    _backupsList.children.clear();
    _commandsList.children.clear();
    _headerContactName.text = '';
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
   * Set the [Contact].name in the widget header.
   */
  set contactName(String name) => _headerContactName.text = name;

  /**
   * Add [items] to the departments list.
   */
  set departments(List<String> items) => _populateList(_departmentList, items);

  /**
   * Add [items] to the email addresses list.
   */
  set emailAddresses(List<String> items) => _populateList(_emailAddressesList, items);

  /**
   * Focus on the telNumList.
   */
  void focusOnTelNumList() {
    _telNumList.focus();
  }

  /**
   * Return the selected [TelNum] from [_telNumList]
   * MAY return null if nothing is selected.
   */
  TelNum getSelectedTelNum() {
    try {
      return new TelNum.fromElement(_telNumList.querySelector('.selected'));
    } catch (e) {
      print(e);
      return null;
    }
  }

  /**
   * Return the [TelNum] the user clicked on.
   * MAY return null if the user did not click on an actual valid [TelNum].
   */
  TelNum getTelNumFromClick(MouseEvent event) {
    try {
      if((event.target is LIElement) || (event.target is SpanElement)) {
        LIElement clickedElement =
            (event.target is SpanElement) ? (event.target as Element).parentNode : event.target;
        return new TelNum.fromElement(clickedElement);
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /**
   * Return the [index] [TelNum] from [_telNumList]
   * MAY return null if index does not exist in the list.
   */
  TelNum getTelNumFromIndex(int index) {
    try {
      return new TelNum.fromElement(_telNumList.children[index]);
    } catch(e) {
      print(e);
      return null;
    }
  }

  /**
   * Return true if [telNum] is marked ringing.
   */
  bool isRinging(TelNum telNum) =>
      telNum.li.classes.contains('ringing');

  /**
   * Return true if [telNum] is marked selected.
   */
  bool isSelected(TelNum telNo) =>
      telNo.li.classes.contains('selected');

  /**
   * Add the [mark] class to the [telNum].
   */
  void _mark(TelNum telNum, String mark) {
    if(telNum != null) {
      _telNumList.children.forEach((Element element) => element.classes.remove(mark));
      telNum.li.classes.add(mark);
      telNum.li.scrollIntoView();
    }
  }

  /**
   * Mark [telNum] ringing. This is NOT the same as actually ringing. It is
   * mere a visual effect.
   */
  void markRinging(TelNum telNum) {
    _mark(telNum, 'ringing');
  }

  /**
   * Mark [telNum] selected.
   */
  void markSelected(TelNum telNum) {
    _mark(telNum, 'selected');
  }

  /**
   * Return the [TelNum] following the currently selected [TelNum].
   * Return null if we're at last element.
   */
  TelNum nextTelNumInList() {
    try {
      LIElement li = _telNumList.querySelector('.selected').nextElementSibling;
      return li != null ? new TelNum.fromElement(li) : null;
    } catch(e) {
      print(e);
      return null;
    }
  }

  /**
   * Return true if no telNumList items are marked "ringing".
   */
  bool get noRinging => !_telNumList.children.any((e) => e.classes.contains('ringing'));

  /**
   *
   */
  void _populateList(OListElement parent, List<String> list) {
    list.forEach((String item) {
      parent.append(new LIElement()..text = item);
    });
  }

  /**
   * Return the [TelNum] preceeding the currently selected [TelNum].
   * Return null if we're at first element.
   */
  TelNum previousTelNumInList() {
    try {
      LIElement li = _telNumList.querySelector('.selected').previousElementSibling;
      return li != null ? new TelNum.fromElement(li) : null;
    } catch(e) {
      print(e);
      return null;
    }
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
   * Add [items] to the telnums list.
   */
  set telnums(List<TelNum> items) => items.forEach((TelNum item) {_telNumList.append(item.li);});

  /**
   * Add [items] to the titles list.
   */
  set titles(List<String> items) => _populateList(_titleList, items);

  /**
   * Add [items] to the workhours list.
   */
  set workHours(List<String> items) => _populateList(_workHoursList, items);
}
