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

final OrganizationList nullOrganizationList = new OrganizationList._null();

/**
 * A list of [Organization] objects.
 */
class OrganizationList extends IterableBase<Organization>{
  List<Organization> _list = new List<Organization>();

  Iterator<Organization> get iterator => _list.iterator;

  /**
   * [OrganizationList] constructor. Builds a list of [Organization] objects
   * from the contents of json[key].
   */
  factory OrganizationList.fromJson(Map json, String key) {
    OrganizationList organizationList = nullOrganizationList;

    if (json.containsKey(key) && json[key] is List) {
      log.debug('model.OrganizationList.fromJson ${key} - ${json[key]}');
      organizationList = new OrganizationList._internal(json[key]);
    } else {
      log.critical('model.OrganizationList.fromJson bad data. Key: ${key}, Map: ${json}');
    }

    return organizationList;
  }

  /**
   * [OrganizationList] internal constructor.
   */
  OrganizationList._internal(List list) {
    list.forEach((item) => _list.add(new Organization.fromJson(item)));
    _list.sort();
  }

  /**
   * [OrganizationList] null constructor.
   */
  OrganizationList._null();
}
