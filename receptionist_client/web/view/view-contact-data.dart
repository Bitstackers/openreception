part of view;

class ContactData {
  static final ContactData _singleton = new ContactData._internal();
  factory ContactData() => _singleton;

  /**
   *
   */
  ContactData._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#contact-data');

  final OListElement _numbers = _root.querySelector('.telephone-numbers');

  void _registerEventListeners() {
    _numbers.querySelectorAll('li').forEach((LIElement number) {
      number.onClick.listen((MouseEvent event) {
        (event.target as LIElement).classes.toggle('selected');
        (event.target as LIElement).classes.toggle('ringing');
      });
    });
  }
}
