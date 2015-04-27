import 'dart:async';
import 'dart:html';

import 'dummies.dart';

import 'enums.dart';
import 'lang.dart' as Lang;
import 'model/model.dart' as Model;
import 'view/view.dart' as View;

void main() {
  /// Make sure we don't steal focus from widgets with mouseclicks on non-widget
  /// elements. This is simply done by searching for the "ignoreclickfocus"
  /// attribute and ignoring mousedown events for those elements.
  document.onMouseDown.listen((MouseEvent event) {
    if((event.target as HtmlElement).attributes.keys.contains('ignoreclickfocus')) {
      event.preventDefault();
    }
  });

  /// Translate the static labels of the app.
  translate();

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
  new Future.delayed(new Duration(milliseconds: 500)).then((_) {
    appState.state = AppState.READY;
  });
}

/**
 * Worlds most simple method to translate widget labels to supported languages.
 */
void translate() {
  Map<String, String> langMap = Lang.da;

  querySelectorAll('[data-lang-text]').forEach((HtmlElement element) {
    element.text = langMap[element.dataset['lang-text']];
  });

  querySelectorAll('[data-lang-placeholder]').forEach((HtmlElement element) {
    element.setAttribute('placeholder', langMap[element.dataset['lang-placeholder']]);
  });
}
