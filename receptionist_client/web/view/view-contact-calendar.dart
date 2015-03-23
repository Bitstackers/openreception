part of view;

class ContactCalendar {
  static final ContactCalendar _singleton = new ContactCalendar._internal();
  factory ContactCalendar() => _singleton;

  /**
   *
   */
  ContactCalendar._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#contact-calendar');

  final Bus<String>  _bus       = new Bus<String>();
  final UListElement _eventList = _root.querySelector('ul');

  /**
   *
   */
  Stream<String> get onEdit => _bus.stream;

  /**
   *
   */
  void _registerEventListeners() {
    _eventList.onClick.listen((_) => _bus.fire('Ret event fra ContactCalendar'));
  }
}
