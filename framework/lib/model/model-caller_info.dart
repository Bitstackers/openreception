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

part of orf.model;

class CallerInfo {
  String name = '?';
  String company = '?';
  String phone = '?';
  String cellPhone = '?';
  String localExtension = '?';

  CallerInfo.empty();

  CallerInfo.fromMap(Map<String, dynamic> map) {
    name = map[key.name];
    company = map[key.company];
    phone = map[key.phone];
    cellPhone = map[key.cellPhone];
    localExtension = map[key.localExtension];
  }

  static CallerInfo decode(Map<String, dynamic> map) =>
      new CallerInfo.fromMap(map);

  @deprecated
  Map<String, dynamic> get asMap => toJson();

  Map<String, dynamic> toJson() => <String, dynamic>{
        key.name: name,
        key.company: company,
        key.phone: phone,
        key.cellPhone: cellPhone,
        key.localExtension: localExtension
      };
}
