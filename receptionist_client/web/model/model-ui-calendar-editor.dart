part of model;

class UICalendarEditor extends UIModel {
  final DivElement _root;

  UICalendarEditor(DivElement this._root);

  ButtonElement   get cancelButton => _root.querySelector('.cancel');
  ButtonElement   get deleteButton => _root.querySelector('.delete');
  HeadingElement  get header       => _root.querySelector('h4');
  ButtonElement   get saveButton   => _root.querySelector('.save');
  InputElement    get startHour    => _root.querySelector('.start-hour');
  InputElement    get startMinute  => _root.querySelector('.start-minute');
  InputElement    get startDay     => _root.querySelector('.start-day');
  InputElement    get startMonth   => _root.querySelector('.start-month');
  InputElement    get startYear    => _root.querySelector('.start-year');
  InputElement    get stopHour     => _root.querySelector('.stop-hour');
  InputElement    get stopMinute   => _root.querySelector('.stop-minute');
  InputElement    get stopDay      => _root.querySelector('.stop-day');
  InputElement    get stopMonth    => _root.querySelector('.stop-month');
  InputElement    get stopYear     => _root.querySelector('.stop-year');
  TextAreaElement get textArea     => _root.querySelector('textarea');
  HtmlElement     get root         => _root;
}
