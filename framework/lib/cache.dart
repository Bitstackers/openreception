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

library utilities.cache;

import 'dart:async';
import 'dart:io';

@deprecated
Future<String> load(String path) => new File(path).readAsString();

@deprecated
Future<List<FileSystemEntity>> list(String path) {
  Directory dir = new Directory(path);
  return dir.list().toList().then((List<FileSystemEntity> values) {
    return values;
  });
}

@deprecated
Future remove(String path) =>  new File(path).delete();

@deprecated
Future rename(String path, String newPath) => new File(path).rename(newPath);

@deprecated
Future save(String path, String text) => new File(path).writeAsString(text);

@deprecated
Future createCacheFolder(String path) {
  Directory dir = new Directory(path);

  //First clear cache, then make the folder again.
  return dir.delete(recursive: true).catchError((_) => null).whenComplete(dir.create);
}
