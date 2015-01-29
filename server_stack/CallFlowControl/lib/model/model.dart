library callflowcontrol.model;

import 'dart:async';
import 'dart:collection';

import 'package:esl/esl.dart' as ESL;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/util.dart'  as Util;
import 'package:openreception_framework/model.dart' as SharedModel;
import 'package:openreception_framework/common.dart';
import '../configuration.dart';
import '../controller/controller.dart' as Controller;
import '../router.dart';

part 'model-call.dart';
part 'model-call_list.dart';
part 'model-pbx_client.dart';
part 'model-client_notification.dart';
part 'model-channel_list.dart';
part 'model-origination_request.dart';
part 'model-peer_list.dart';
part 'model-transfer_request.dart';
part 'model-user_status_list.dart';

const String libraryName = 'callflowcontrol.model';
