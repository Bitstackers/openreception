library menu;

import 'dart:html';

import 'lib/eventbus.dart';

class Menu {
  static const String ORGANIZATION_WINDOW = 'organization';
  static const String RECEPTION_WINDOW = 'reception';
  static const String CONTACT_WINDOW = 'contact';
  static const String DIALPLAN_WINDOW = 'dialplan';
  static const String RECORD_WINDOW = 'record';

  HtmlElement element;

  ImageElement orgButton, recButton, conButton, dialButton, recordButton;

  Menu(HtmlElement this.element) {
    orgButton = element.querySelector('#organization-button');
    recButton = element.querySelector('#reception-button');
    conButton = element.querySelector('#contact-button');
    dialButton = element.querySelector('#dialplan-button');
    recordButton = element.querySelector('#record-button');

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

    bus.on(windowChanged).listen((Map event) {
      _highlightItem(event['window']);
    });
  }

  void _highlightItem(String window) {
    orgButton.style.opacity = window == ORGANIZATION_WINDOW ? '1': '0.2';
    recButton.style.opacity = window == RECEPTION_WINDOW ? '1': '0.2';
    conButton.style.opacity = window == CONTACT_WINDOW ? '1': '0.2';
    dialButton.style.opacity = window == DIALPLAN_WINDOW ? '1': '0.2';
    recordButton.style.opacity = window == RECORD_WINDOW ? '1': '0.2';
  }
}
