part of view;

class ReceptionCommands {
  static final ReceptionCommands _singleton = new ReceptionCommands._internal();
  factory ReceptionCommands() => _singleton;

  /**
   *
   */
  ReceptionCommands._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#reception-commands');

  final UListElement _commandList = _root.querySelector('ul');
  final Place        _here        = new Place('context-home', _root.id);

  /**
   *
   */
  void _registerEventListeners() {
    _root    .onClick.listen((_) => _activateMe(_root, _here));
    _hotKeys .onAltH .listen((_) => _activateMe(_root, _here));
    _navigate.onGo   .listen((Place place) => _setWidgetState(_root, _commandList, place));
  }
}
