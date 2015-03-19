part of view;

class ContactData {
  static final ContactData _singleton = new ContactData._internal();
  factory ContactData() => _singleton;

  final DivElement   root    = querySelector('#contact-data');
  final OListElement numbers = querySelector('#contact-data .telephone-numbers');

  ContactData._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    numbers.querySelectorAll('li').forEach((LIElement number) {
      number.onClick.listen((MouseEvent event) {
        (event.target as LIElement).classes.toggle('selected');
        (event.target as LIElement).classes.toggle('ringing');
      });
    });
  }
}
