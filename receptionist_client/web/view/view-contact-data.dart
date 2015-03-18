part of view;

class ContactData {
  static final ContactData _singleton = new ContactData._internal();
  factory ContactData() => _singleton;

  UListElement ul = querySelector('#reception-calendar ul');

  Bus<String> bus = new Bus<String>();

  ContactData._internal() {
    registerEventListeners();
  }

  Stream<String> get onEdit => bus.stream;

  void registerEventListeners() {
    ul.onClick.listen((_) => bus.fire('Ret event fra ReceptionCalendar'));
  }
}
