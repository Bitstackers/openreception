part of view;

class ContactCalendar {
  static final ContactCalendar _singleton = new ContactCalendar._internal();
  factory ContactCalendar() => _singleton;

  final Bus<String>  bus = new Bus<String>();
  final UListElement eventList = querySelector('#contact-calendar ul');
  final DivElement   root      = querySelector('#contact-calendar');

  ContactCalendar._internal() {
    registerEventListeners();
  }

  Stream<String> get onEdit => bus.stream;

  void registerEventListeners() {
    eventList.onClick.listen((_) => bus.fire('Ret event fra ContactCalendar'));
  }
}
