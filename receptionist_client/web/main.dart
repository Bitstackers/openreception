import 'dart:async';
import 'dart:html';

import 'controller/controller.dart';
import 'model/model.dart';
import 'view/view.dart';

void main() {
  ApplicationState appState = new ApplicationState();

  ReceptionistclientDisaster appDisaster = new ReceptionistclientDisaster(appState);
  ReceptionistclientLoading  appLoading  = new ReceptionistclientLoading(appState);
  ReceptionistclientReady    appReady    = new ReceptionistclientReady(appState);

  /// TODO (TL): The loading context is visible by default. Switch to ready after
  /// 1 second.
  new Future.delayed(new Duration(milliseconds: 200)).then((_) {
    appState.state = AppState.Ready;
  });
}
