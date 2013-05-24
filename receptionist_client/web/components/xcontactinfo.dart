import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/model.dart' as model;

class ContactInfo extends WebComponent {
  String calendarTitle = 'Kalender';
  String placeholder = 'søg...';
  String title = 'Medarbejdere';

  @observable model.Contact contact = model.nullContact;

  void inserted() {
    //_queryElements();
    //_registerEventListeners();
    //_resize();
    _registerObservers();
  }

  void _queryElements() {

  }

  void _registerEventListeners() {
    window.onResize.listen((_) => _resize());
  }

  void _registerObservers() {
    observe(() => environment.organization, (_) {
      contact = environment.organization.current.contactList.first;
    });
  }

  void _resize() {
    //this.query('[name="foo"]').style.height = '70%';
  }

  void select(Event event) {
    int id = int.parse((event.target as LIElement).id.split('_').last);
    contact = environment.organization.current.contactList.getContact(id);
  }
}
