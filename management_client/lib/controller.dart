library management_tool.controller;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/model.dart' as model;

part 'controller/controller-calendar.dart';
part 'controller/controller-cdr.dart';
part 'controller/controller-contact.dart';
part 'controller/controller-distribution_list.dart';
part 'controller/controller-dialplan.dart';
part 'controller/controller-endpoint.dart';
part 'controller/controller-ivr.dart';
part 'controller/controller-message.dart';
part 'controller/controller-popup.dart';
part 'controller/controller-organization.dart';
part 'controller/controller-reception.dart';
part 'controller/controller-user.dart';

final Popup popup = new Popup(
    new Uri.file('/image/popup_error.png'),
    new Uri.file('/image/popup_info.png'),
    new Uri.file('/image/popup_success.png'));
