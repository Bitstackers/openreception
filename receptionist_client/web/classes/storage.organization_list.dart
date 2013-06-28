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

part of storage;

final _OrganizationList organizationList = new _OrganizationList();

/**
 * Storage class for the Organization List object.
 */
class _OrganizationList{
  _OrganizationList();

  /**
   * Get the organization list from Alice.
   */
  void get(OrganizationListSubscriber onComplete, {Callback onError}) {
//    new protocol.OrganizationList()
//        ..onResponse((protocol.Response response) {
//          switch(response.status){
//            case protocol.Response.OK:
//              onComplete(new model.OrganizationList.fromMap(response.data));
//              break;
//
//            default:
//              onError();
//          }
//        })
//        ..send();

    protocol.getOrganizationList()
      .then((protocol.Response response) {
        switch(response.status){
          case protocol.Response.OK:
              onComplete(new model.OrganizationList.fromJson(response.data, 'organization_list'));
              break;

            default:
              onError();
          }
      })
      .catchError((e) {
        log.error('Storage OrganizationList got and error from protocol.');
      });
  }
}

