/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

/**
 * The Bob client. Helping receptionists do their work every day.
 */
import 'dart:async';
import 'dart:html';

import 'classes/bobactive.dart';
import 'classes/bobdisaster.dart';
import 'classes/bobloading.dart';
//import 'classes/boblogin.dart';
import 'classes/configuration.dart';
import 'classes/events.dart' as event;
import 'classes/location.dart' as nav;
import 'classes/logger.dart';
import 'classes/service-notification.dart';
import 'protocol/protocol.dart' as protocol;
import 'classes/state.dart';

import 'view/view.dart' as View;

import 'model/model.dart' as Model;

BobActive bobActive;
BobDisaster bobDiaster;
BobLoading bobLoading;
//BobLogin boblogin;

void main() {
  
  View.Notification notificationPanel = new View.Notification();
  
  configuration.initialize().then((_) {
    if(handleToken()) {
      notification.initialize();
    }      
  });
  
  
  //boblogin = new BobLogin(querySelector('#boblogin'));

  //notification.initialize();
  //configuration.initialize();

  bobLoading = new BobLoading(querySelector('#bobloading'));
  bobDiaster = new BobDisaster(querySelector('#bobdisaster'));

  StreamSubscription subscription;
  subscription = event.bus.on(event.stateUpdated).listen((State state) {
    if(state.isOK) {
      bobActive = new BobActive(querySelector('#bobactive'));
      subscription.cancel();
      
      nav.registerOnPopStateListeners();
      /// Reload the model.
      Model.CallList.instance.reloadFromServer();
    }
  });
}

bool handleToken() {
  Uri url = Uri.parse(window.location.href);
  //TODO Save to localStorage.
  if(url.queryParameters.containsKey('settoken')) {
    configuration.token = url.queryParameters['settoken'];
    
    //Remove ?settoken from the URL
    Map queryParam = {};
    url.queryParameters.forEach((key, value) {
      if(key != 'settoken') {
        queryParam[key] = value;
      }
    });
    var finalUrl = new Uri(scheme: url.scheme, userInfo: url.userInfo, host: url.host, port: url.port, path: url.path, queryParameters: queryParam, fragment: url.fragment);
    //window.location.assign(finalUrl.toString());
    //Didn't work. try localStorage.
    
    protocol.userInfo(configuration.token).then((protocol.Response<Map> response) {
      Map data = response.data;
      configuration.profile = data;
      if(data.containsKey('id')) {
        //TODO: remove these.
        configuration.userId = data['id'];
        configuration.userName = data['name'];
        
        Model.User.currentUser = new Model.User (data['id'],data['name']);
        
        
      } else {
        //TODO: Panic action.
        log.error('bob.dart userInfo did not contain an id');
      }
    }) ;
    return true;
  } else {
    String loginUrl = '${configuration.authBaseUrl}/token/create?returnurl=${window.location.toString()}';
    window.location.assign(loginUrl);
    return false;
  }
}


