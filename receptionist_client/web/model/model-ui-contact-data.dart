part of model;

class UIContactData extends UIModel {
  final DivElement _root;

  UIContactData(DivElement this._root);

  @override HtmlElement get firstTabElement => null;
  @override HtmlElement get lastTabElement  => null;
  @override HtmlElement get focusElement    => telNoList;
  @override HtmlElement get root            => _root;

  @override set firstTabElement(_) => null;
  @override set focusElement(_)    => null;
  @override set lastTabElement(_)  => null;

  UListElement get additionalInfoList => _root.querySelector('.additional-info');
  bool         get noRinging          => !telNoList.children.any((e) => e.classes.contains('ringing'));
  UListElement get backupList         => _root.querySelector('.backup');
  UListElement get commandsList       => _root.querySelector('.commands');
  UListElement get departmentList     => _root.querySelector('.department');
  UListElement get emailAddressesList => _root.querySelector('.email-addresses');
  UListElement get relationsList      => _root.querySelector('.relations');
  UListElement get responsibilityList => _root.querySelector('.responsibility');
  OListElement get telNoList          => _root.querySelector('.telephone-number');
  UListElement get titleList          => _root.querySelector('.title');
  UListElement get workHoursList      => _root.querySelector('.work-hours');

  void addTelNo(TelNo telNo) {
    telNoList.append(telNo._li);
  }

  TelNo getTelNoFromClick(MouseEvent event) {
    if((event.target is LIElement) || (event.target is SpanElement)) {
      LIElement clickedElement =
          (event.target is SpanElement) ? (event.target as Element).parentNode : event.target;
      return new TelNo.fromElement(clickedElement);
    }

    return null;
  }

  /**
   * Return the [index] [TelNo] from [telNoList]
   * MAY return null if index does not exist in the list.
   */
  TelNo getTelNoFromIndex(int index) {
    try {
      return new TelNo.fromElement(telNoList.children[index]);
    } catch(e) {
      return null;
    }
  }

  bool isRinging(TelNo telNo) =>
      telNo._li.classes.contains('ringing');

  bool isSelected(TelNo telNo) =>
      telNo._li.classes.contains('selected');

  void mark(TelNo telNo, String mark) {
    telNoList.children.forEach((Element element) => element.classes.remove(mark));
    telNo._li.classes.add(mark);
    telNo._li.focus();
  }

  void markRinging(TelNo telNo) {
    mark(telNo, 'ringing');
  }

  void markSelected(TelNo telNo) {
    mark(telNo, 'selected');
  }

  TelNo nextTelNoInList() =>
      new TelNo.fromElement(telNoList.querySelector('.selected').nextElementSibling);

  TelNo previousTelNoInList() =>
      new TelNo.fromElement(telNoList.querySelector('.selected').previousElementSibling);

  void selectTelNo(TelNo telNo) {
    if(active && telNo != null && noRinging) {
      if(isSelected(telNo)) {
        markRinging(telNo);
      } else {
        markSelected(telNo);
      }
    }
  }
}

/**
 * A telephone number.
 */
class TelNo {
  LIElement   _li         = new LIElement()..tabIndex = -1;
  bool        _secret;
  SpanElement _spanLabel  = new SpanElement();
  SpanElement _spanNumber = new SpanElement();

  TelNo(String number, String label, this._secret) {
    if(_secret) {
      _spanNumber.classes.add('secret');
    }

    _spanNumber.text = number;
    _spanNumber.classes.add('number');
    _spanLabel.text = label;
    _spanLabel.classes.add('label');

    _li.children.addAll([_spanNumber, _spanLabel]);
    _li.dataset['number'] = number;
  }

  TelNo.fromElement(LIElement element) {
    _li = element;
  }
}
