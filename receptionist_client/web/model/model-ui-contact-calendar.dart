part of model;

class UIContactCalendar extends UIModel {
  final DivElement _root;

  UIContactCalendar(DivElement this._root);

  @override HtmlElement get firstTabElement => null;
  @override HtmlElement get lastTabElement  => null;
  @override HtmlElement get focusElement    => entryList;
  @override HtmlElement get root            => _root;

  @override set firstTabElement(_) => null;
  @override set focusElement(_)    => null;
  @override set lastTabElement(_)  => null;

  UListElement get entryList => _root.querySelector('ul');
}
