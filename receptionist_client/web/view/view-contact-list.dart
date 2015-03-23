part of view;

class ContactList {
  static final ContactList _singleton = new ContactList._internal();
  factory ContactList() => _singleton;

  /**
   *
   */
  ContactList._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#contact-list');

  final InputElement _filter = _root.querySelector('.filter');
  final UListElement _list   = _root.querySelector('.generic-widget-list');

  void _registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
