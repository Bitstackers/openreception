part of model;

class UIReceptionCalendar extends UIModel {
  final DivElement _myRoot;

  UIReceptionCalendar(DivElement this._myRoot);

  @override HtmlElement    get _firstTabElement => null;
  @override HtmlElement    get _focusElement    => _entryList;
  @override HeadingElement get _header          => _root.querySelector('h4');
  @override DivElement     get _help            => _root.querySelector('div.help');
  @override HtmlElement    get _lastTabElement  => null;
  @override HtmlElement    get _root            => _myRoot;

  UListElement get _entryList => _root.querySelector('ul');
}
