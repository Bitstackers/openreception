part of model;

class DomReceptionCommands extends DomModel {
  final DivElement _root;

  DomReceptionCommands(DivElement this._root);

  UListElement get commandList => _root.querySelector('ul');

  @override
  HtmlElement  get root        => _root;
}
