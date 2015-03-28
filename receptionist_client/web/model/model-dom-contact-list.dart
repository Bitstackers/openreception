part of model;

class DomContactList extends DomModel {
  final DivElement _root;

  DomContactList(DivElement this._root);

  UListElement get contactList => _root.querySelector('.generic-widget-list');
  InputElement get filter      => _root.querySelector('.filter');

  @override
  HtmlElement get root => _root;
}
