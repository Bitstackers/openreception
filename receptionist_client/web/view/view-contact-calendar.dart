part of view;

class ContactCalendar {
  static final ContactCalendar _singleton = new ContactCalendar._internal();
  factory ContactCalendar() => _singleton;

  UListElement ul = querySelector('#contact-calendar ul');

  Bus<String> bus = new Bus<String>();

  ContactCalendar._internal() {
    registerEventListeners();
  }

  Stream<String> get onEdit => bus.stream;

  void registerEventListeners() {
    ul.onClick.listen((_) => bus.fire('Ret event fra ContactCalendar'));
  }
}
