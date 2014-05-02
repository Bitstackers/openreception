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

part of model;

/**
 * A list of [BasicReception] objects.
 */
class ReceptionList extends IterableBase<BasicReception>{
  List<BasicReception> _list = new List<BasicReception>();

  Iterator<BasicReception> get iterator => _list.iterator;

  /**
   * [ReceptionList] constructor.
   */
  ReceptionList();

  /**
   * [ReceptionList] constructor. Builds a list of [BasicReception] objects
   * from the contents of json[key].
   */
  factory ReceptionList.fromJson(Map json, String key) {
    ReceptionList receptionList = new ReceptionList();

    if (json.containsKey(key) && json[key] is List) {
      log.dataDump('model.ReceptionList.fromJson key: ${key} list: ${json[key]}', 'model.ReceptionList');
      receptionList = new ReceptionList._fromList(json[key]);
    } else {
      log.critical('model.ReceptionList.fromJson bad data key: ${key} map: ${json}');
    }

    return receptionList;
  }

  /**
   * [ReceptionList] from list constructor.
   */
  ReceptionList._fromList(List<Map> list) {
    list.forEach((item) => _list.add(new BasicReception.fromJson(item)));
    _list.sort();
  }
}
