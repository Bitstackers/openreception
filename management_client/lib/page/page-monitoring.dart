library management_tool.page.monitoring;

import 'dart:async';
import 'dart:html';

//import 'package:logging/logging.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/view.dart' as view;
import 'package:openreception.framework/event.dart' as event;
import 'package:route_hierarchical/client.dart';

/**
 *
 */
class Monitoring {
  //final Logger _log = new Logger('management_tool.page.monitoring');

  final DivElement element = new DivElement()
    ..id = "monitoring-page"
    ..hidden = true
    ..classes.addAll(['page']);

  final controller.User _userController;
  final Router _router;

  view.AgentInfoList _agentView;

  /**
   *
   */
  Monitoring(
      controller.Call callController,
      controller.User this._userController,
      Stream<event.UserState> userStateChange,
      Stream<event.PeerState> peerStateChange,
      Stream<event.WidgetSelect> widgetSelect,
      Stream<event.FocusChange> focusChange,
      this._router) {
    _setupRouter();

    _agentView = new view.AgentInfoList(callController, _userController,
        userStateChange, peerStateChange, widgetSelect, focusChange);

    element.children = [_agentView.element];
  }

  /**
   *
   */
  Future activate(RouteEvent e) async {
    element.hidden = false;
    loading = true;
    await _agentView.render();
    loading = false;
  }

  /**
   *
   */
  void deactivate(RouteEvent e) {
    element.hidden = true;
  }

  /**
   *
   */
  void _setupRouter() {
    print('setting up monitor router');
    _router.root
      ..addRoute(
          name: 'monitor',
          enter: activate,
          path: '/monitor',
          leave: deactivate);
  }

  /**
   *
   */
  void set loading(bool isLoading) {
    element.classes.toggle('loading', isLoading);
  }
}
