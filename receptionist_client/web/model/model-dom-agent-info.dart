part of model;

class DomAgentInfo extends DomModel {
  final DivElement _root;

  DomAgentInfo(DivElement this._root);

  TableCellElement get activeCount => _root.querySelector('.active-count');
  ImageElement     get agentState  => _root.querySelector('.agent-state');
  ImageElement     get alertState  => _root.querySelector('.alert-state');
  ImageElement     get face        => _root.querySelector('.face');
  TableCellElement get pausedCount => _root.querySelector('.paused-count');

  @override
  HtmlElement      get root        => _root;
}
