part of view;

class ContactList {
  static final ContactList _singleton = new ContactList._internal();
  factory ContactList() => _singleton;

  final DivElement root = querySelector('#contact-list');

  ContactList._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
