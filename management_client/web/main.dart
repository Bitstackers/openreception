// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:management_tool/view.dart' as view;
import 'package:management_tool/controller.dart' as controller;

import 'package:route_hierarchical/client.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as model;
import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-html.dart' as transport;

import 'lib/auth.dart';
import 'lib/configuration.dart';

final Uri CONFIGURATION_URL = Uri.parse('http://localhost:4080');

var _jsonpp = new JsonEncoder.withIndent('  ');
view.IvrMenuView ivrView;
view.Dialplan dpView;
service.RESTIvrStore _ivrStore;
service.RESTDialplanStore _dialplanStore;


Future main() async {
  Logger _log = new Logger('main');
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  final transport.Client client = new transport.Client();
  config.clientConfig =
      await (new service.RESTConfiguration(config.configUri, client))
          .clientConfig();

//  if (!handleToken()) {
//    _log.warning('Authentication failure');
//    return;
//  }

  model.ClientConfiguration clientConfig =
      await new service.RESTConfiguration(
          CONFIGURATION_URL, new transport.Client()).clientConfig();

  _ivrStore = new service.RESTIvrStore(
      clientConfig.dialplanServerUri, config.token, new transport.Client());

  _dialplanStore = new service.RESTDialplanStore(
      clientConfig.dialplanServerUri, config.token, new transport.Client());

  controller.Dialplan dpController = new controller.Dialplan
      (new service.RESTDialplanStore(
      clientConfig.dialplanServerUri, config.token, new transport.Client()));

  dpView = new view.Dialplan(dpController);
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
    ..addRoute(name: 'organizations', path: '/organization', enter: _showOrganizationList)

    ..addRoute(name: 'ivr-list', path: '/ivr', enter: showIvrList)
    ..addRoute(name: 'ivr-create', path: '/ivr/create', enter: createIvr)
    ..addRoute(name: 'ivr', path: '/ivr/:id', enter: showIvr)
    ..addRoute(name: 'dialplan', path: '/dialplan/:id', enter: showDialplan)
    ..addRoute(
        name: 'dialplan-list', path: '/dialplan', enter: showDialplanList);

  router.listen();
}

createIvr(RouteEnterEvent e) {
  (querySelector('textarea.ivr-edit') as TextAreaElement).value = _jsonpp
      .convert(new model.IvrMenu(
          'new', new model.Playback('...', wrapInLock: false)));
  ivrView.menu = currentIvrMenu();
}

Future showIvr(RouteEvent e) async {
  String menuName = e.parameters['id'];

  (querySelector('textarea.ivr-edit') as TextAreaElement).value =
      _jsonpp.convert(await _ivrStore.get(menuName));
  ivrView.menu = currentIvrMenu();
}

Future showDialplanList(RouteEnterEvent e) async {
  querySelectorAll('section:not(.hidden)').classes.toggle('hidden', true);
  querySelectorAll('#dialplans').classes.toggle('hidden', false);
  querySelector('#dialplan-list').replaceWith((new view.DialplanList()
    ..menus = await _dialplanStore.list()).element..id = 'dialplan-list');
}

Future showIvrList(RouteEnterEvent e) async {
  querySelectorAll('section:not(.hidden)').classes.toggle('hidden', true);
  querySelectorAll('#ivr-menus').classes.toggle('hidden', false);
  querySelector('#ivr-menu-list').replaceWith((new view.IvrMenuList()
    ..menus = await _ivrStore.list()).element..id = 'ivr-menu-list');
}

Future showDialplan(RouteEnterEvent e) async {
  final String extension = e.parameters['id'];

  (querySelector('#dialplan-edit') as TextAreaElement).value =
      _jsonpp.convert(await _dialplanStore.get(extension));
  dpView.dialplan = currentDialplan();
}

Future _showOrganizationList(RouteEnterEvent e) async {
  querySelectorAll('section:not(.hidden)').classes.toggle('hidden', true);
  querySelector('section#organizations').classes.toggle('hidden', false);
  querySelector('section#organizations').
    children = [
      new view.Organization().element];
}

model.IvrMenu currentIvrMenu() {
  try {
    //querySelector('.dialplan-view-widget').classes.toggle('hidden', false);
    querySelector('#ivr-menus .error-console')
      ..classes.toggle('hidden', true)
      ..text = '';
    return model.IvrMenu.decode(JSON
        .decode((querySelector('textarea.ivr-edit') as TextAreaElement).value));
  } catch (error, stackTrace) {
    querySelector('.dialplan-view-widget').classes.toggle('hidden', true);
    querySelector('#ivr-menus .error-console')
      ..classes.toggle('hidden', false)
      ..text = '$error \n\n$stackTrace';
    return new model.IvrMenu(
        '...', new model.Playback('...', wrapInLock: false));
  }
}

model.ReceptionDialplan currentDialplan() {
  try {
    querySelector('.dialplan-view-widget').classes.toggle('hidden', false);
    querySelector('#dialplans .error-console')
      ..classes.toggle('hidden', true)
      ..text = '';
    return model.ReceptionDialplan.decode(JSON
        .decode((querySelector('#dialplan-edit') as TextAreaElement).value));
  } catch (error, stackTrace) {
    querySelector('.dialplan-view-widget').classes.toggle('hidden', true);
    querySelector('#dialplans .error-console')
      ..classes.toggle('hidden', false)
      ..text = '$error \n\n$stackTrace';
    return new model.ReceptionDialplan();
  }
}
