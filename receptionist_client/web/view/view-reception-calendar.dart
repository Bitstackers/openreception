part of view;

class ReceptionCalendar {
  static final ReceptionCalendar _singleton = new ReceptionCalendar._internal();
  factory ReceptionCalendar() => _singleton;

  /**
   *
   */
  ReceptionCalendar._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#reception-calendar');

  final Bus<String>  _bus       = new Bus<String>();
  final UListElement _eventList = _root.querySelector('ul');
  final Place        _here      = new Place('context-home', _root.id);

  /**
   *
   */
  Stream<String> get onEdit => _bus.stream;

  /**
   *
   */
  void _registerEventListeners() {
    _root    .onClick.listen((_) => _activateMe(_root, _here));
    _hotKeys .onAltA .listen((_) => _activateMe(_root, _here));
    _navigate.onGo   .listen((Place place) => _setWidgetState(_root, _eventList, place));

    // TODO (TL): temporary stuff
    _eventList.onDoubleClick.listen((_) => _bus.fire('Ret event fra ReceptionCalendar'));
  }
}
