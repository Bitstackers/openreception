library callflowcontrol.model;

import 'dart:async';
import 'dart:collection';

import 'package:esl/esl.dart' as ESL; 
import 'package:OpenReceptionFramework/service.dart' as Service;
import 'package:OpenReceptionFramework/model.dart' as SharedModel;
import 'package:OpenReceptionFramework/common.dart';
import '../configuration.dart';
import '../controller/controller.dart' as Controller;

part 'model-call.dart';
part 'model-call_list.dart';
part 'model-pbx_client.dart';
part 'model-client_notification.dart';
part 'model-channel_list.dart';
part 'model-origination_request.dart';
part 'model-peer_list.dart';
part 'model-transfer_request.dart';

const String libraryName = 'callflowcontrol.model';