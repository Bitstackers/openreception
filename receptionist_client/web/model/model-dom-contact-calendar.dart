part of model;

class DomContactCalendar extends DomModel {
  final DivElement _root;

  DomContactCalendar(DivElement this._root);

  UListElement get eventList => _root.querySelector('ul');

  @override
  HtmlElement get root => _root;
}
