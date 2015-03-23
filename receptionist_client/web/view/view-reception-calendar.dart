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
  final Place        _here      = new Place('context-home', 'reception-calendar');
  final Navigate     _navigate  = new Navigate();

  /**
   *
   */
  Stream<String> get onEdit => _bus.stream;

  /**
   *
   */
  void onNavigate(Place place) {
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
      }
    });

    _navigate.onGo.listen(onNavigate);

    _eventList.onDoubleClick.listen((_) => _bus.fire('Ret event fra ReceptionCalendar'));
  }
}
