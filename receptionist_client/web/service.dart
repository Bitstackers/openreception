library service;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'classes/logger.dart';

import 'classes/protocol.dart';
import 'classes/model.dart' as model;
import 'classes/configuration.dart';

part 'service/service-message.dart';

final String libraryName = "service"; 

class Request {
  
  bool   _useCredientials = true;
  String _token           = configuration.token; 
  
  Request (Uri, String method, [bool useCredentials, String token]) {
    if (useCredentials != null) {
      this._useCredientials = useCredentials;
    }

    if (token != null) {
      this._token = token;
    }
  }
  
}