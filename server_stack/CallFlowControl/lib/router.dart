library callflowcontrol.router;

import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'package:OpenReceptionFramework/common.dart';
import 'package:OpenReceptionFramework/httpserver.dart';

import 'controller/controller.dart' as Controller;
import 'model/model.dart' as Model;
import 'package:OpenReceptionFramework/model.dart' as SharedModel;
import 'package:OpenReceptionFramework/service.dart' as Service;
import 'package:OpenReceptionFramework/model.dart';

part 'router/handler-call-hangup.dart';
part 'router/handler-call-list.dart';
part 'router/handler-call-originate.dart';
part 'router/handler-call-park.dart';
part 'router/handler-call-pickup.dart';
part 'router/handler-call-queue.dart';
part 'router/handler-call-transfer.dart';
part 'router/handler-channel-list.dart';
part 'router/handler-peer-list.dart';

const String libraryName = "notificationserver.router";

Map<int,List<WebSocket>> clientRegistry = new Map<int,List<WebSocket>>();

final Pattern peerListResource       = new UrlPattern(r'/peer/list');
final Pattern callListResource       = new UrlPattern(r'/call/list');
final Pattern callQueueResource      = new UrlPattern(r'/call/queue');
final Pattern callHangupResource     = new UrlPattern(r'/call/([a-z\-0-9]+)/hangup');
final Pattern callPickupResource     = new UrlPattern(r'/call/([a-z\-0-9]+)/pickup');
final Pattern callParkResource       = new UrlPattern(r'/call/([a-z\-0-9]+)/park');
final Pattern callTransferResource   = new UrlPattern(r'/call/([a-z\-0-9]+)/transfer/([a-z\-0-9]+)');
final Pattern callOriginateResource  = new UrlPattern(r'/call/originate/([a-z\-0-9]+)/reception/(\d+)/contact/(\d+)');
final Pattern callPickupNextResource = new UrlPattern(r'/call/pickup');
final Pattern channelListResource    = new UrlPattern(r'/channel/list');

final List<Pattern> allUniqueUrls = [peerListResource,
                                     callListResource, callQueueResource, callHangupResource,
                                     callParkResource, callOriginateResource, 
                                     callPickupNextResource, callTransferResource, 
                                     callPickupNextResource];

void registerHandlers(HttpServer server) {
    logger.debugContext("CallFlowControl REST interface is listening on "
             "'http://${server.address.address}:${config.httpport}/'", "registerHandlers");
    var router = new Router(server);

    router
      ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
      ..serve(  peerListResource,     method : "GET"  ).listen(handlerPeerList)
      ..serve(  callListResource,     method : "GET"  ).listen(handlerCallList)
      ..serve(channelListResource,    method : "GET"  ).listen(handlerChannelList)
      ..serve(  callQueueResource,    method : "GET"  ).listen(handlerCallQueue)
      ..serve(callHangupResource,     method : "POST" ).listen(handlerCallHangup)
      ..serve(callPickupResource,     method : "POST" ).listen(handlerCallPickup)
      ..serve(callParkResource,       method : "POST" ).listen(handlerCallPark)
      ..serve(callOriginateResource , method : "POST" ).listen(handlerCallOrignate)
      ..serve(callTransferResource,   method : "POST" ).listen(handlerCallTransfer)
      ..serve(callPickupNextResource, method : "POST" ).listen(handlerCallPickupNext)
      ..defaultStream.listen(page404);
}

