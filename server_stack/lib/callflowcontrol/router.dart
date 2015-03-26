library callflowcontrol.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/httpserver.dart';

import 'controller/controller.dart' as Controller;
import 'model/model.dart' as Model;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:esl/esl.dart' as ESL;

part 'router/handler-user_state.dart';
part 'router/handler-call.dart';
part 'router/handler-channel.dart';
part 'router/handler-peer.dart';

const String libraryName = "callflowcontrol.router";

Map<int,List<WebSocket>> clientRegistry = new Map<int,List<WebSocket>>();
Service.Authentication AuthService = null;
Service.NotificationService Notification = null;

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern peerListResource           = new UrlPattern(r'/peer/list');
final Pattern userStateResource          = new UrlPattern(r'/userstate/(\d+)');
final Pattern userStateIdleResource      = new UrlPattern(r'/userstate/(\d+)/idle');
final Pattern userStatePausedResource    = new UrlPattern(r'/userstate/(\d+)/paused');
final Pattern userStateListResource      = new UrlPattern(r'/userstate');
final Pattern callListResource           = new UrlPattern(r'/call');
final Pattern callHangupSpecificResource = new UrlPattern(r'/call/([a-z\-0-9]+)/hangup');
final Pattern callPickupResource         = new UrlPattern(r'/call/([a-z\-0-9]+)/pickup');
final Pattern callResource               = new UrlPattern(r'/call/([a-z\-0-9]+)');
final Pattern callParkResource           = new UrlPattern(r'/call/([a-z\-0-9]+)/park');
final Pattern callTransferResource       = new UrlPattern(r'/call/([a-z\-0-9]+)/transfer/([a-z\-0-9]+)');
final Pattern callOriginateResource      = new UrlPattern(r'/call/originate/([a-z\-\:\.\@0-9]+)/reception/(\d+)/contact/(\d+)');
final Pattern callPickupNextResource     = new UrlPattern(r'/call/pickup');
final Pattern callRecordSoundResource    = new UrlPattern(r'/call/reception/(\d+)/record');
final Pattern channelListResource        = new UrlPattern(r'/channel/list');

final List<Pattern> allUniqueUrls = [peerListResource,
                                     userStateResource, userStateListResource,
                                     callListResource,
                                     callParkResource, callOriginateResource,
                                     callPickupNextResource, callTransferResource,
                                     callRecordSoundResource];

void connectAuthService() {
  AuthService = new Service.Authentication
      (config.authUrl, config.serverToken, new Service_IO.Client());
}

void connectNotificationService() {
  Notification = new Service.NotificationService
      (config.notificationServer, config.serverToken, new Service_IO.Client());
}

void registerHandlers(HttpServer server) {
    logger.debugContext("CallFlowControl REST interface is listening on "
             "'http://${server.address.address}:${config.httpport}/'", "registerHandlers");
    var router = new Router(server);

    router
      ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
      ..serve(userStateResource,          method : "GET"  ).listen(UserState.get)
      ..serve(userStateIdleResource,      method : "POST" ).listen(UserState.markIdle)
      ..serve(userStatePausedResource,    method : "POST" ).listen(UserState.markPaused)
      ..serve(userStateListResource,      method : "GET"  ).listen(UserState.list)
      ..serve(peerListResource,           method : "GET"  ).listen(Peer.list)
      ..serve(callResource,               method : "GET"  ).listen(Call.get)
      ..serve(callListResource,           method : "GET"  ).listen(Call.list)
      ..serve(channelListResource,        method : "GET"  ).listen(Channel.list)
      ..serve(callHangupSpecificResource, method : "POST" ).listen(Call.hangupSpecific)
      ..serve(callPickupResource,         method : "POST" ).listen(Call.pickup)
      ..serve(callParkResource,           method : "POST" ).listen(Call.park)
      ..serve(callOriginateResource,      method : "POST" ).listen(Call.originate)
      ..serve(callTransferResource,       method : "POST" ).listen(Call.transfer)
      ..serve(callRecordSoundResource,    method : "POST" ).listen(Call.recordSound)
      ..serve(anything,                   method : 'OPTIONS').listen(preFlight)
      ..defaultStream.listen(page404);
}

