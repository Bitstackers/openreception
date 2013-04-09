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

part of storage;

final _StorageOrganizationList storageOrganizationList = new _StorageOrganizationList();

/**
 * Storage class for the Organization List object.
 */
class _StorageOrganizationList{
  _StorageOrganization_List();

  /**
   * Get the organization list from Alice.
   */
  void get(OrganizationListSubscriber onComplete) {
    new protocol.OrganizationList()
        ..onSuccess((text) {
          onComplete(new OrganizationList.fromMap(json.parse(text)));
        })
        ..onError(() {
          //TODO Do something.
        })
        ..send();
  }
}

