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
 * A list of [BasicOrganization] objects.
 */
class OrganizationList extends IterableBase<BasicOrganization>{
  List<BasicOrganization> _list = new List<BasicOrganization>();

  Iterator<BasicOrganization> get iterator => _list.iterator;

  /**
   * [OrganizationList] constructor.
   */
  OrganizationList();

  /**
   * [OrganizationList] constructor. Builds a list of [BasicOrganization] objects
   * from the contents of json[key].
   */
  factory OrganizationList.fromJson(Map json, String key) {
    OrganizationList organizationList = new OrganizationList();

    if (json.containsKey(key) && json[key] is List) {
      log.debug('model.OrganizationList.fromJson key: ${key} list: ${json[key]}');
      organizationList = new OrganizationList._fromList(json[key]);
    } else {
      log.critical('model.OrganizationList.fromJson bad data key: ${key} map: ${json}');
    }

    return organizationList;
  }

  /**
   * [OrganizationList] from list constructor.
   */
  OrganizationList._fromList(List<Map> list) {
    list.forEach((item) => _list.add(new BasicOrganization.fromJson(item)));
    _list.sort();
  }
}
