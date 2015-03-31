part of model;

class UIReceptionCalendar extends UIModel {
  final DivElement _root;

  UIReceptionCalendar(DivElement this._root);

  UListElement get eventList => _root.querySelector('ul');

  @override
  HtmlElement  get root      => _root;
}
