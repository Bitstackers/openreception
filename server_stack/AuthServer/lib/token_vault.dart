library TokenVault;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'configuration.dart';
import 'package:Utilities/cache.dart' as IO;
import 'package:Utilities/common.dart';

TokenVault vault = new TokenVault();

class TokenVault {
  Map<String, Map> _tokens = new Map<String, Map>();

  Map getToken(String token) {
    if(_tokens.containsKey(token)) {
      return _tokens[token];
    } else {
      throw new Exception('getToken. Unknown token: ${token}');
    }
  }

  void insertToken(String token, Map data) {
    print(data);
    if(_tokens.containsKey(token)) {
      throw new Exception('insertToken. Token allready exists: $token');
    } else {
      _tokens[token] = data;
    }
  }

  void updateToken(String token, Map data) {
    if(_tokens.containsKey(token)) {
      _tokens[token] = data;
    } else {
      throw new Exception('updateToken. Unknown token: ${token}');
    }
  }

  bool containsToken(String token) => _tokens.containsKey(token);

  void removeToken(String token) {
    if(_tokens.containsKey(token)) {
      _tokens.remove(token);
    } else {
      throw new Exception('containsToken. Unknown token: ${token}');
    }
  }

  Iterable<String> listTokens() {
    return _tokens.keys;
  }

  Future loadFromDirectory(String directory) {
    if(directory != null) {
      return IO.list(directory).then((List<FileSystemEntity> list) {

        return Future.forEach(list, (FileSystemEntity item) {
          if(item is File) {
            IO.load(item.path).then((String text) {
              //TODO handle systems that do not seperate folders with "/"
              String token = item.path.split('/').last.split('.').first;
              Map data = JSON.decode(text);
              insertToken(token, data);

            }).catchError((error) {
              log('TokenVault.loadFromDirectory() ${error}');
            });
          }
        });

      });
    } else {
      return new Future.value();
    }
  }
}