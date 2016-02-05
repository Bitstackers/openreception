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
 * Provides methods for manipulating the contact data UI widget.
 */
class UIContactData extends UIModel {
  final Bus<ORModel.PhoneNumber> _busRinging = new Bus<ORModel.PhoneNumber>();
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIContactData(DivElement this._myRoot) {
    _observers();
  }

  @override HtmlElement get _firstTabElement => _root;
  @override HtmlElement get _focusElement => _root;
  @override HtmlElement get _lastTabElement => _root;
  @override HtmlElement get _listTarget => _phoneNumberList;
  @override HtmlElement get _root => _myRoot;

  OListElement get _additionalInfoList => _root.querySelector('.additional-info');
  OListElement get _backupsList => _root.querySelector('.backups');
  OListElement get _commandsList => _root.querySelector('.commands');
  OListElement get _departmentList => _root.querySelector('.department');
  OListElement get _emailAddressesList => _root.querySelector('.email-addresses');
  DivElement get _popupDiv => _root.querySelector('.popup');
  InputElement get _pstnInput => _root.querySelector('.popup .pstn');
  OListElement get _relationsList => _root.querySelector('.relations');
  OListElement get _responsibilityList => _root.querySelector('.responsibility');
  SpanElement get _showPSTNSpan => _root.querySelector('.show-pstn');
  SpanElement get _showTagsSpan => _root.querySelector('.show-tags');
  OListElement get _tagsList => _root.querySelector('.popup .generic-widget-list');
  OListElement get _phoneNumberList => _root.querySelector('.telephone-number');
  OListElement get _titleList => _root.querySelector('.title');
  OListElement get _workHoursList => _root.querySelector('.work-hours');

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
   *
   * If removePopup is true, then also remove the PSTN/Tags popup. Else leave it.
   */
  void clear({bool removePopup: false}) {
    _headerExtra.text = '';
    _additionalInfoList.children.clear();
    _backupsList.children.clear();
    _commandsList.children.clear();
    _departmentList.children.clear();
    _emailAddressesList.children.clear();
    _relationsList.children.clear();
    _responsibilityList.children.clear();
    _tagsList.children.clear();
    _pstnInput.value = '';
    _phoneNumberList.children.clear();
    _titleList.children.clear();
    _workHoursList.children.clear();

    if (removePopup) {
      _showPSTNSpan.classes.toggle('active', false);
      _showTagsSpan.classes.toggle('active', false);
      _popupDiv.classes.toggle('popup-hidden', true);
    }
  }

  /**
   * Add [items] ot the commands list.
   */
  set commands(List<String> items) => _populateList(_commandsList, items);

  /**
   * Populate widget with [cwfc.contact] data and mark tags according to the
   * filter context.
   */
  set contactWithFilterContext(ContactWithFilterContext cwfc) {
    clear();

    headerExtra = ': ${cwfc.contact.fullName}';
    additionalInfo = cwfc.contact.infos;
    backups = cwfc.contact.backupContacts;
    commands = cwfc.contact.handling;
    departments = cwfc.contact.departments;
    emailAddresses = cwfc.contact.emailaddresses;
    relations = cwfc.contact.relations;
    responsibility = cwfc.contact.responsibilities;
    tags = cwfc;
    telephoneNumbers = cwfc.contact.phones;
    titles = cwfc.contact.titles;
    workHours = cwfc.contact.workhours;

    if (_showPSTNSpan.classes.contains('active')) {
      _showPSTNSpan.classes.toggle('active', false);
      _popupDiv.classes.toggle('popup-hidden', true);
      _focusElement.focus();
    }
  }

  /**
   * Add [items] to the departments list.
   */
  set departments(List<String> items) => _populateList(_departmentList, items);

  /**
   * Add [items] to the email addresses list.
   */
  set emailAddresses(List<String> items) => _populateList(_emailAddressesList, items);

  /**
   * Return true if no phonenumbers are marked "ringing".
   */
  bool get noRinging => !_phoneNumberList.children.any((e) => e.classes.contains('ringing'));

  /**
   * Observers
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen(_selectFromClick);

    _hotKeys.onAltArrowDown.listen((_) => _markSelected(_scanForwardForVisibleElement(
        _phoneNumberList.querySelector('.selected')?.nextElementSibling)));

    _hotKeys.onAltArrowUp.listen((_) => _markSelected(_scanBackwardForVisibleElement(
        _phoneNumberList.querySelector('.selected')?.previousElementSibling)));

    _hotKeys.onCtrlSpace.listen((_) => _togglePopup(_showTagsSpan));

    _showPSTNSpan.onClick.listen((MouseEvent event) => _togglePopup(event.target));
    _showTagsSpan.onClick.listen((MouseEvent event) => _togglePopup(event.target));
  }

  /**
   * Fires when a [ORModel.PhoneNumber] is marked ringing.
   */
  Stream<ORModel.PhoneNumber> get onMarkedRinging => _busRinging.stream;

  /**
   * Appends each of the [list] elements to [parent]
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
   * Removes the ringing effect from whatever element that might currently be marked ringing.
   *
   * Removing the effect is delayed by 500ms for usability reasons.
   */
  void removeRinging() {
    new Future.delayed(new Duration(milliseconds: 500), () {
      final Element elem = _root.querySelector('.ringing');

      if (elem != null) {
        elem.classes.toggle('ringing', false);
      }
    });
  }

  /**
   * Add [items] to the responsibility list.
   */
  set responsibility(List<String> items) => _populateList(_responsibilityList, items);

  /**
   * Mark selected [ORModel.PhoneNumber] ringing if we're not already ringing. If the PSTN input
   * field is active and contains something, then call that.
   *
   * This fires a [ORModel.PhoneNumber] object on the [onMarkedRinging] stream.
   */
  void ring() {
    if (_showPSTNSpan.classes.contains('active') && _pstnInput.value.trim().isNotEmpty) {
      ORModel.PhoneNumber phoneNumber = new ORModel.PhoneNumber.empty()
        ..endpoint = _pstnInput.value.trim();
      _pstnInput.classes.toggle('ringing', true);
      _busRinging.fire(phoneNumber);
    } else {
      LIElement li = _phoneNumberList.querySelector('.selected');

      if (li != null && noRinging) {
        li.classes.toggle('ringing');
        _busRinging.fire(new ORModel.PhoneNumber.fromMap(JSON.decode(li.dataset['object'])));
      }
    }
  }

  /**
   * Select the first [ORModel.PhoneNumber] in the list.
   */
  void selectFirstPhoneNumber() {
    if (_phoneNumberList.children.isNotEmpty) {
      _markSelected(_scanForwardForVisibleElement(_phoneNumberList.children.first));
    }
  }

  /**
   * Mark a [LIElement] in the telephone number list selected, if one such is the target of the
   * [event].
   */
  void _selectFromClick(MouseEvent event) {
    if (event.target is LIElement && (event.target as LIElement).parent == _phoneNumberList) {
      _markSelected(event.target);
    }
  }

  /**
   * Add [items] to the tags list.
   */
  set tags(ContactWithFilterContext cwfc) {
    final List<String> filterParts = new List<String>()
      ..addAll(cwfc.state == filterState.tag ? cwfc.filterValue.split(' ') : new List<String>());
    filterParts.removeWhere((String f) => f.trim().length < 2);
    cwfc.contact.tags.forEach((String item) {
      final LIElement li = new LIElement()..text = item;
      li.classes.toggle(
          'found',
          cwfc.state == filterState.tag &&
              filterParts.any((String f) => item.toLowerCase().contains(f)));
      _tagsList.append(li);
    });
  }

  /**
   * Add [items] to the telephone number list.
   */
  set telephoneNumbers(List<ORModel.PhoneNumber> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((ORModel.PhoneNumber item) {
      final SpanElement spanLabel = new SpanElement();
      final SpanElement spanNumber = new SpanElement();

      spanNumber.classes.toggle('secret', item.confidential);
      spanNumber.classes.add('number');
      spanNumber.text = item.endpoint;

      spanLabel.classes.add('label');
      spanLabel.text = item.description;

      list.add(new LIElement()
        ..children.addAll([spanNumber, spanLabel])
        ..dataset['object'] = JSON.encode(item));
    });

    _phoneNumberList.children = list;
  }

  /**
   * Add [items] to the titles list.
   */
  set titles(List<String> items) => _populateList(_titleList, items);

  /**
   * Show/hide the popup.
   *
   * Venture forth at your own peril!
   */
  void _togglePopup(HtmlElement target) {
    if (_popupDiv.classes.contains('popup-hidden')) {
      _popupDiv.classes.toggle('popup-hidden', false);

      if (target == _showPSTNSpan) {
        _showPSTNSpan.classes.toggle('active', true);
        _tagsList.style.display = 'none';
        _pstnInput.style.display = 'inline';
        new Future.delayed(new Duration(milliseconds: 1)).then((_) => _pstnInput.focus());
      } else {
        _showTagsSpan.classes.toggle('active', true);
        _pstnInput.style.display = 'none';
        _tagsList.style.display = 'block';
      }
    } else {
      if (target == _showPSTNSpan && _showPSTNSpan.classes.contains('active')) {
        _showPSTNSpan.classes.toggle('active', false);
        _popupDiv.classes.toggle('popup-hidden', true);
        _focusElement.focus();
      } else if (target == _showTagsSpan && _showTagsSpan.classes.contains('active')) {
        _showTagsSpan.classes.toggle('active', false);
        _popupDiv.classes.toggle('popup-hidden', true);
      } else if (target == _showPSTNSpan && _showTagsSpan.classes.contains('active')) {
        _tagsList.style.display = 'none';
        _pstnInput.style.display = 'inline';
        _showTagsSpan.classes.toggle('active', false);
        _showPSTNSpan.classes.toggle('active', true);
        new Future.delayed(new Duration(milliseconds: 1)).then((_) => _pstnInput.focus());
      } else if (target == _showTagsSpan && _showPSTNSpan.classes.contains('active')) {
        _pstnInput.style.display = 'none';
        _tagsList.style.display = 'block';
        _showPSTNSpan.classes.toggle('active', false);
        _showTagsSpan.classes.toggle('active', true);
        _focusElement.focus();
      } else {
        // This is bonkers! Why are we here!! Hide the popup and remove .active
        _showPSTNSpan.classes.toggle('active', false);
        _showTagsSpan.classes.toggle('active', false);
        _popupDiv.classes.toggle('popup-hidden', true);
        _focusElement.focus();
      }
    }
  }

  /**
   * Add [items] to the workhours list.
   */
  set workHours(List<String> items) => _populateList(_workHoursList, items);
}
