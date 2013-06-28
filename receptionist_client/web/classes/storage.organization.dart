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

final _Organization organization = new _Organization();

/**
 * Storage class for Organization objects.
 *
 * TODO Make it possible to invalidate cached items.
 */
class _Organization{
  Map<int, model.Organization> _cache = new Map<int, model.Organization>();

  _Organization();

  /**
   * Fetch an organization by [id] from Alice if there is no cache of it.
   */
  void get(int id, OrganizationSubscriber onComplete, {Callback onError}) {
    if (_cache.containsKey(id)) {
      onComplete(_cache[id]);
    } else {
      protocol.getOrganization(id)
        .then((protocol.Response response) {
            switch(response.status) {
              case protocol.Response.OK:
                model.Organization org = new model.Organization.fromJson(response.data);
                _cache[org.id] = org;
                onComplete(org);
                break;

              case protocol.Response.NOTFOUND:
                onComplete(model.nullOrganization);
                break;

              default:
                onError();
            }
        })
        .catchError((_) {
          log.error('Storage organization. Protocol getOrganization gave an error.');
        });
    }
  }
}
