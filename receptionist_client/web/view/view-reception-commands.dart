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
  final Place        _here        = new Place('context-home', 'reception-commands');
  final Navigate     _navigate    = new Navigate();

  /**
   *
   */
  void _onNavigate(Place place) {
    if(_root.id == place.widgetId) {
      _root.focus();
      _root.classes.toggle('focus', true);
    } else {
      _root.blur();
      _root.classes.toggle('focus', false);
    }
  }

  /**
   *
   */
  void _registerEventListeners() {
    _root.onClick.listen((_) {
      if(!_root.classes.contains('focus')) {
        _navigate.go(_here);
      } else {
        print("ReceptionCommands I'm already active!");
      }
    });

    _navigate.onGo.listen(_onNavigate);
  }
}
