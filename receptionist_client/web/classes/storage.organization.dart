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

final Storage_Organization storageOrganization = new Storage_Organization._internal();

/**
 * Storage class for Organization objects.
 */
class Storage_Organization{
  Storage_Organization._internal();

  //TODO Make it possible to invalidate cached items.
  var _cache = new Map<int, Organization>();

  /**
   * Gets an organization by [id] from alice if there is no cache of it.
   */
  void get(int id, OrganizationSubscriber onComplete) {
    if (_cache.containsKey(id)) {
      onComplete(_cache[id]);

    }else{
      log.debug('${id} is not cached');
      new protocol.Organization.get(id)
          ..onSuccess((text) {
            var organizationJson = json.parse(text);
            //TODO Should not read information directly from json. Read from org.
            int id = organizationJson['organization_id'];
            var org = new Organization(organizationJson);
            _cache[id] = org;
            onComplete(org);
          })
          ..onNotFound((){
            //TODO Do something.
          })
          ..onError((){
            //TODO Do something.
          })
          ..send();
    }
  }

  /**
   * Get the organization list from alice.
   */
  void getList(OrganizationListSubscriber onComplete) {
    new protocol.OrganizationList()
        ..onSuccess((text) {
          var res = new OrganizationList(json.parse(text));
          onComplete(res);
        })
        ..onError(() {
          //TODO Do something.
        })
        ..send();
  }
}