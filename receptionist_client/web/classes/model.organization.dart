/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/
part of model;

/**
 * TODO comment, write this when the class have more to it, then a simple map.
 */
class Organization{
  Map _json;
  //Map get json => _json;

  List _contacts;
  List get contacts => _contacts;

  Map _orgInfo;
  Map get orgInfo => _orgInfo;

  Organization(Map json) {
    _json = new Map.from(json);

    _contacts = json['contacts'];

    json.remove('contacts');
    _orgInfo = json;
  }

  Organization._null() {
    _orgInfo = null;
    _contacts = null;
  }

  String toString() => _json.toString();
}

Organization nullOrganization = new Organization._null();
