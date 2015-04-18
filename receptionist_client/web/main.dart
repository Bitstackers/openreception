import 'dart:async';
import 'dart:html';

import 'dummies.dart';

import 'controller/controller.dart' as Controller;
import 'enums.dart';
import 'model/model.dart' as Model;
import 'view/view.dart' as View;

void main() {
  AppClientState appState = new AppClientState();

  final Model.UIReceptionistclientDisaster uiDisaster = new Model.UIReceptionistclientDisaster('receptionistclient-disaster');
  final Model.UIReceptionistclientLoading  uiLoading  = new Model.UIReceptionistclientLoading('receptionistclient-loading');
  final Model.UIReceptionistclientReady    uiReady    = new Model.UIReceptionistclientReady('receptionistclient-ready');

  View.ReceptionistclientDisaster appDisaster = new View.ReceptionistclientDisaster(appState, uiDisaster);
  View.ReceptionistclientLoading  appLoading  = new View.ReceptionistclientLoading(appState, uiLoading);

  /// This is where it all starts. Every single widget is instantiated in
  /// appReady.
  View.ReceptionistclientReady appReady = new View.ReceptionistclientReady(appState, uiReady);

  /// TODO (TL): The loading context is visible by default. Switch to ready after
  /// 1 second.
  new Future.delayed(new Duration(milliseconds: 200)).then((_) {
    appState.state = AppState.READY;
  });
}
