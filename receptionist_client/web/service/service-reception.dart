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

part of service;

abstract class Reception {

  static ORStorage.Reception _store = null;

  static ORStorage.Reception get store {
    if (_store == null) {
      _store = new ORService.RESTReceptionStore
          (configuration.receptionBaseUrl,
           configuration.token,
           new ORServiceHTML.Client());
    }

    return _store;
  }

}
