library tokenWatch; 

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'cache.dart';
import 'configuration.dart';
import 'package:Utilities/cache.dart' as cacheUtil;
import 'package:Utilities/common.dart';

void setup() {
  print('Watcher started');
  //TODO this should be an isolate
  int minutes = 10;
  new Timer.periodic(new Duration(seconds: minutes), _timerTick);
}

Future seen(String token) {
  return loadToken(token).then((String text) {
    Map contentAsJson = JSON.decode(text);
    contentAsJson['expiresAt'] = dateTimeToJson(new DateTime.now().add(config.tokenexpiretime));
    return saveToken(token, JSON.encode(contentAsJson));
  });
}

void _timerTick(Timer timer) {
  listTokens().then((List<FileSystemEntity> list) {
    for(FileSystemEntity item in list) {      
      if(item is File) {
        cacheUtil.load(item.path).then((String text) {
          Map contentAsJson = JSON.decode(text);
          DateTime expiresAt = JsonToDateTime(contentAsJson['expiresAt']);
          
          //TODO handle systems that do not seperate folders with "/"
          String token = item.path.split('/').last.split('.').first;
          var now = new DateTime.now().millisecondsSinceEpoch;
          if(now > expiresAt.millisecondsSinceEpoch) {
            logger.debug('tokenWatch._timerTick() This token ${token} expired ${expiresAt}');
            return removeToken(token); 
          }
        }).catchError((error) {
          log('tokenWatch._timerTick() ${error}');
        });
      }
    }
  });
}