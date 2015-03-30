part of model;

class UIContactList extends UIModel {
  final DivElement _root;

  UIContactList(DivElement this._root);

  UListElement get contactList => _root.querySelector('.generic-widget-list');
  InputElement get filter      => _root.querySelector('.filter');

  @override
  HtmlElement get root => _root;
}
