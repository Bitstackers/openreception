part of model;

class DomReceptionCalendar extends DomModel {
  final DivElement _root;

  DomReceptionCalendar(DivElement this._root);

  UListElement get eventList => _root.querySelector('ul');

  @override
  HtmlElement  get root      => _root;
}
