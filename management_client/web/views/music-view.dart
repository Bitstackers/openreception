library music.view;

import 'dart:html';

import '../lib/eventbus.dart';

class MusicView {
  String viewName = 'ivr';
  DivElement element;
  ButtonElement buttonNew, buttonSave, ButtonDelete;

  MusicView(DivElement this.element) {
    buttonNew = element.querySelector('#music-new');
    buttonSave = element.querySelector('#music-save');
    ButtonDelete = element.querySelector('#music-delete');

  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
    });
  }
}
