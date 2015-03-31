part of model;

class UIReceptionCommands extends UIModel {
  final DivElement _root;

  UIReceptionCommands(DivElement this._root);

  UListElement get commandList => _root.querySelector('ul');

  @override
  HtmlElement  get root        => _root;
}
