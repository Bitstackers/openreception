/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.authentication_server.token_vault;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:openreception_framework/storage.dart' as storage;
import 'package:path/path.dart' as path;

TokenVault vault = new TokenVault();

const String libraryName = 'AuthServer.TokenVault';

class TokenVault {
  static final Logger log = new Logger('$libraryName.TokenVault');

  Map<String, Map> _userTokens = new Map<String, Map>();
  Map<String, Map> _serverTokens = new Map<String, Map>();

  Map getToken(String token) {
    if (_userTokens.containsKey(token)) {
      return _userTokens[token];
    } else if (_serverTokens.containsKey(token)) {
      return _serverTokens[token];
    } else {
      throw new storage.NotFound('getToken. Unknown token: ${token}');
    }
  }

  void insertToken(String token, Map data) {
    log.finest('Inserting new token: $data');
    if (_userTokens.containsKey(token)) {
      log.severe('Duplicate token: $token');
      throw new Exception('insertToken. Token allready exists: $token');
    } else {
      _userTokens[token] = data;
    }
  }

  void updateToken(String token, Map data) {
    if (_userTokens.containsKey(token)) {
      _userTokens[token] = data;
    } else if (_serverTokens.containsKey(token)) {
      return;
    } else {
      throw new Exception('updateToken. Unknown token: ${token}');
    }
  }

  bool containsToken(String token) =>
      _userTokens.containsKey(token) || _serverTokens.containsKey(token);

  void removeToken(String token) {
    if (_userTokens.containsKey(token)) {
      _userTokens.remove(token);
    } else {
      throw new Exception('containsToken. Unknown token: ${token}');
    }
  }

  Iterable<String> listUserTokens() {
    return _userTokens.keys;
  }

  Future loadFromDirectory(String directory) {
    if (directory != null && directory.isNotEmpty) {
      return list(directory).then((List<FileSystemEntity> list) {
        return Future.forEach(list, (FileSystemEntity item) {
          if (item is File) {
            load(item.path).then((String text) {
              String token = path.basenameWithoutExtension(item.path);
              Map data = JSON.decode(text);
              _serverTokens[token] = data;
              log.finest('Loaded ${_serverTokens[token]}');
            }).catchError((error) {
              log.severe('TokenVault.loadFromDirectory() ${error}');
            });
          }
        });
      });
    } else {
      return new Future.value();
    }
  }

  Future<List<FileSystemEntity>> list(String path) =>
      new Directory(path).list().toList();

  Future<String> load(String path) => new File(path).readAsString();
}
