import 'dart:async';
import 'dart:html';

import 'model/dummies.dart';

import 'controller/controller.dart' as Controller;
import 'enums.dart';
import 'model/model.dart' as Model;
import 'view/view.dart' as View;

void main() {
  AppClientState appState = new AppClientState();

  View.ReceptionistclientDisaster appDisaster = new View.ReceptionistclientDisaster(appState);
  View.ReceptionistclientLoading  appLoading  = new View.ReceptionistclientLoading(appState);
  View.ReceptionistclientReady    appReady    = new View.ReceptionistclientReady(appState);

  /// TODO (TL): The loading context is visible by default. Switch to ready after
  /// 1 second.
  new Future.delayed(new Duration(milliseconds: 200)).then((_) {
    appState.state = AppState.READY;
  });
}
