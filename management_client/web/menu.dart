library menu;

import 'dart:html';

import 'lib/eventbus.dart';

class Menu {
  static const String ORGANIZATION_WINDOW = 'organization';
  static const String RECEPTION_WINDOW = 'reception';
  static const String CONTACT_WINDOW = 'contact';
  static const String DIALPLAN_WINDOW = 'dialplan';
  static const String RECORD_WINDOW = 'record';
  static const String USER_WINDOW = 'user';
  static const String BILLING_WINDOW = 'billing';

  HtmlElement element;

  ImageElement orgButton, recButton, conButton,
               dialButton, recordButton, userButton,
               billingButton;

  Menu(HtmlElement this.element) {
    orgButton = element.querySelector('#organization-button');
    recButton = element.querySelector('#reception-button');
    conButton = element.querySelector('#contact-button');
    dialButton = element.querySelector('#dialplan-button');
    recordButton = element.querySelector('#record-button');
    userButton = element.querySelector('#user-button');
    billingButton = element.querySelector('#billing-button');

    orgButton.onClick.listen((_) {
      Map event = {
        'window': ORGANIZATION_WINDOW
      };
      bus.fire(windowChanged, event);
    });

    recButton.onClick.listen((_) {
      Map event = {
        'window': RECEPTION_WINDOW
      };
      bus.fire(windowChanged, event);
    });

    conButton.onClick.listen((_) {
      Map event = {
        'window': CONTACT_WINDOW
      };
      bus.fire(windowChanged, event);
    });

    dialButton.onClick.listen((_) {
      Map event = {
        'window': DIALPLAN_WINDOW
      };
      bus.fire(windowChanged, event);
    });

    recordButton.onClick.listen((_) {
      Map event = {
        'window': RECORD_WINDOW
      };
      bus.fire(windowChanged, event);
    });

    userButton.onClick.listen((_) {
      Map event = {
        'window': USER_WINDOW
      };
      bus.fire(windowChanged, event);
    });

    billingButton.onClick.listen((_) {
      Map event = {
        'window': BILLING_WINDOW
      };
      bus.fire(windowChanged, event);
    });

    bus.on(windowChanged).listen((Map event) {
      _highlightItem(event['window']);
    });
  }

  void _highlightItem(String window) {
    orgButton.classes.toggle('faded', window != ORGANIZATION_WINDOW);
    recButton.classes.toggle('faded', window != RECEPTION_WINDOW);
    conButton.classes.toggle('faded', window != CONTACT_WINDOW);
    dialButton.classes.toggle('faded', window != DIALPLAN_WINDOW);
    recordButton.classes.toggle('faded', window != RECORD_WINDOW);
    userButton.classes.toggle('faded', window != USER_WINDOW);
    billingButton.classes.toggle('faded', window != BILLING_WINDOW);
  }
}
