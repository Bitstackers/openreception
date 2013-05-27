import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/model.dart' as model;

class ContactInfo extends WebComponent {
  String calendarTitle = 'Kalender';
  String placeholder = 'søg...';
  String title = 'Medarbejdere';

  @observable model.Contact contact = model.nullContact;

  void created() {
    _registerObservers();
  }

  void _registerObservers() {
    observe(() => environment.organization, (_) {
      contact = environment.organization.current.contactList.first;
    });
  }

  void select(Event event) {
    int id = int.parse((event.target as LIElement).id.split('_').last);
    contact = environment.organization.current.contactList.getContact(id);
  }
}
