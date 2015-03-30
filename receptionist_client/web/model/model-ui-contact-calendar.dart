part of model;

class UIContactCalendar extends UIModel {
  final DivElement _root;

  UIContactCalendar(DivElement this._root);

  UListElement get eventList => _root.querySelector('ul');

  @override
  HtmlElement get root => _root;
}
