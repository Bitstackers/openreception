part of model;

class UIReceptionCommands extends UIModel {
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIReceptionCommands(DivElement this._myRoot);

  @override HtmlElement    get _firstTabElement => null;
  @override HtmlElement    get _focusElement    => _commandList;
  @override HeadingElement get _header          => _root.querySelector('h4');
  @override DivElement     get _help            => _root.querySelector('div.help');
  @override HtmlElement    get _lastTabElement  => null;
  @override HtmlElement    get _root            => _myRoot;

  OListElement get _commandList => _root.querySelector('.generic-widget-list');

  /**
   * Add [items] to the commands list.
   */
  set commands(List<Command> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((Command item) {
      list.add(new LIElement()
                ..dataset['object'] = JSON.encode(item)
                ..text = item.command);
    });

    _commandList.children = list;
  }
}
