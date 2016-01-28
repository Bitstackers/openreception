// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:management_tool/view.dart' as view;
import 'package:route_hierarchical/client.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:openreception_framework/service.dart' as ORService;
import 'package:openreception_framework/service-html.dart' as ORTransport;

final Uri CONFIGURATION_URL = Uri.parse('http://localhost:4080');
final String token = 'secretstuff';

var _jsonpp = new JsonEncoder.withIndent('  ');
view.IvrMenuView ivrView;
view.DialplanView dpView;
ORService.RESTIvrStore _ivrStore;
ORService.RESTDialplanStore _dialplanStore;
Future main() async {
  ORModel.ClientConfiguration clientConfig =
      await new ORService.RESTConfiguration(
          CONFIGURATION_URL, new ORTransport.Client()).clientConfig();

  _ivrStore = new ORService.RESTIvrStore(
      clientConfig.dialplanServerUri, token, new ORTransport.Client());

  _dialplanStore = new ORService.RESTDialplanStore(
      clientConfig.dialplanServerUri, token, new ORTransport.Client());

  dpView = new view.DialplanView();
  querySelector('#dialplan-view').replaceWith(dpView.element);

  ivrView = new view.IvrMenuView();
  querySelector('div.ivr-preview')
      .replaceWith(ivrView.element..classes.toggle('ivr-preview', true));

  (querySelector('textarea.ivr-edit') as TextAreaElement).onInput.listen((_) {
    ivrView.menu = currentIvrMenu();
  });

  dpView.dialplan = currentDialplan();
  (querySelector('#dialplan-edit') as TextAreaElement).onInput.listen((_) {
    dpView.dialplan = currentDialplan();
  });

  // Webapps need routing to listen for changes to the URL.
  var router = new Router();
  router.root
    ..addRoute(name: 'ivr-list', path: '/ivr', enter: showIvrList)
    ..addRoute(name: 'ivr-create', path: '/ivr/create', enter: createIvr)
    ..addRoute(name: 'ivr', path: '/ivr/:id', enter: showIvr)
    ..addRoute(name: 'dialplan', path: '/dialplan/:id', enter: showDialplan)
    ..addRoute(
        name: 'dialplan-list', path: '/dialplan', enter: showDialplanList);
  router.listen();
}

createIvr(_) {
  (querySelector('textarea.ivr-edit') as TextAreaElement).value = _jsonpp
      .convert(new ORModel.IvrMenu(
          'new', new ORModel.Playback('...', wrapInLock: false)));
  ivrView.menu = currentIvrMenu();
}

Future showIvr(RouteEvent e) async {
  String menuName = e.parameters['id'];

  (querySelector('textarea.ivr-edit') as TextAreaElement).value =
      _jsonpp.convert(await _ivrStore.get(menuName));
  ivrView.menu = currentIvrMenu();
}

Future showDialplanList(_) async {
  querySelectorAll('section:not(.hidden)').classes.toggle('hidden', true);
  querySelectorAll('#dialplans').classes.toggle('hidden', false);
  querySelector('#dialplan-list').replaceWith((new view.DialplanList()
    ..menus = await _dialplanStore.list()).element..id = 'dialplan-list');
}

Future showIvrList(_) async {
  querySelectorAll('section:not(.hidden)').classes.toggle('hidden', true);
  querySelectorAll('#ivr-menus').classes.toggle('hidden', false);
  querySelector('#ivr-menu-list').replaceWith((new view.IvrMenuList()
    ..menus = await _ivrStore.list()).element..id = 'ivr-menu-list');
}

Future showDialplan(RouteEvent e) async {
  final String extension = e.parameters['id'];

  (querySelector('#dialplan-edit') as TextAreaElement).value =
      _jsonpp.convert(await _dialplanStore.get(extension));
  dpView.dialplan = currentDialplan();
}

ORModel.IvrMenu currentIvrMenu() {
  try {
    //querySelector('.dialplan-view-widget').classes.toggle('hidden', false);
    querySelector('#ivr-menus .error-console')
      ..classes.toggle('hidden', true)
      ..text = '';
    return ORModel.IvrMenu.decode(JSON
        .decode((querySelector('textarea.ivr-edit') as TextAreaElement).value));
  } catch (error, stackTrace) {
    querySelector('.dialplan-view-widget').classes.toggle('hidden', true);
    querySelector('#ivr-menus .error-console')
      ..classes.toggle('hidden', false)
      ..text = '$error \n\n$stackTrace';
    return new ORModel.IvrMenu(
        '...', new ORModel.Playback('...', wrapInLock: false));
  }
}

ORModel.ReceptionDialplan currentDialplan() {
  try {
    querySelector('.dialplan-view-widget').classes.toggle('hidden', false);
    querySelector('#dialplans .error-console')
      ..classes.toggle('hidden', true)
      ..text = '';
    return ORModel.ReceptionDialplan.decode(JSON
        .decode((querySelector('#dialplan-edit') as TextAreaElement).value));
  } catch (error, stackTrace) {
    querySelector('.dialplan-view-widget').classes.toggle('hidden', true);
    querySelector('#dialplans .error-console')
      ..classes.toggle('hidden', false)
      ..text = '$error \n\n$stackTrace';
    return new ORModel.ReceptionDialplan();
  }
}
