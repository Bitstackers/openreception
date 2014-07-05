library menu;

import 'dart:html';

import 'lib/eventbus.dart';

class Menu {
  static const String ORGANIZATION_WINDOW = 'organization';
  static const String RECEPTION_WINDOW = 'reception';
  static const String CONTACT_WINDOW = 'contact';
  static const String DIALPLAN_WINDOW = 'dialplan';
  static const String IVR_WINDOW = 'ivr';
  static const String RECORD_WINDOW = 'record';
  static const String USER_WINDOW = 'user';
  static const String BILLING_WINDOW = 'billing';
  static const String MUSIC_WINDOW = 'music';

  HtmlElement element;

  Map<String, ImageElement> menus;

  Menu(HtmlElement this.element) {
    //Build up collections of menus
    menus = {
       'organization': element.querySelector('#organization-button'),
       'reception': element.querySelector('#reception-button'),
       'contact': element.querySelector('#contact-button'),
       'dialplan': element.querySelector('#dialplan-button'),
       'ivr': element.querySelector('#ivr-button'),
       'record': element.querySelector('#record-button'),
       'user': element.querySelector('#user-button'),
       'billing': element.querySelector('#billing-button'),
       'music': element.querySelector('#music-button'),
      };

    //Register onClicker handler, and emit an event about window change.
    menus.forEach((String name, ImageElement button) {
      button.onClick.listen((_) {
        Map event = {
          'window': name
        };
        bus.fire(windowChanged, event);
      });
    });

    //When there comes an windowChange event, highlight the right button.
    bus.on(windowChanged).listen((Map event) {
      _highlightItem(event['window']);
    });
  }

  //Highlights the right button.
  void _highlightItem(String window) {
    menus.forEach((String name, ImageElement button) {
      button.classes.toggle('faded', window != name);
    });
  }
}
