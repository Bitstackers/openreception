part of model;

class UICalendarEditor extends UIModel {
  HtmlElement      _firstTabElement;
  HtmlElement      _focusElement;
  HtmlElement      _lastTabElement;
  final DivElement _root;

  UICalendarEditor(DivElement this._root);

  ButtonElement   get cancelButtonElement => _root.querySelector('.cancel');
  ButtonElement   get deleteButtonElement => _root.querySelector('.delete');
  HtmlElement     get firstTabElement     => _firstTabElement;
  HtmlElement     get focusElement        => _focusElement;
  HeadingElement  get headerElement       => _root.querySelector('h4');
  HtmlElement     get lastTabElement      => _lastTabElement;
  HtmlElement     get root                => _root;
  ButtonElement   get saveButtonElement   => _root.querySelector('.save');
  InputElement    get startHourElement    => _root.querySelector('.start-hour');
  InputElement    get startMinuteElement  => _root.querySelector('.start-minute');
  InputElement    get startDayElement     => _root.querySelector('.start-day');
  InputElement    get startMonthElement   => _root.querySelector('.start-month');
  InputElement    get startYearElement    => _root.querySelector('.start-year');
  InputElement    get stopHourElement     => _root.querySelector('.stop-hour');
  InputElement    get stopMinuteElement   => _root.querySelector('.stop-minute');
  InputElement    get stopDayElement      => _root.querySelector('.stop-day');
  InputElement    get stopMonthElement    => _root.querySelector('.stop-month');
  InputElement    get stopYearElement     => _root.querySelector('.stop-year');
  TextAreaElement get textAreaElement     => _root.querySelector('textarea');
  bool            get validInput =>
      !_root.querySelectorAll('input').any((InputElement element) => element.value.isEmpty) &&
          textAreaElement.value.isNotEmpty;

  set firstTabElement(HtmlElement element) => _firstTabElement = element;
  set focusElement   (HtmlElement element) => _focusElement    = element;
  set lastTabElement (HtmlElement element) => _lastTabElement  = element;
}
