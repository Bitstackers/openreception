library billing_view;

import 'dart:html';

import '../lib/eventbus.dart';

class BillingView {
  String viewName = 'billing';
  DivElement element;

  BillingView(DivElement this.element) {

    registrateEventHandlers();
  }


  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
    });

  }
}