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

library Common;

import 'model.dart' as model;
import 'protocol.dart' as protocol;

typedef void Subscriber(Map json);
typedef void responseCallback(protocol.Response response);
typedef void Callback();
typedef void OrganizationSubscriber (model.Organization organization);
typedef void OrganizationListSubscriber (model.OrganizationList organizationList);

/**
 * A simple timeout exception. MUST be used wherever we throw exceptions due
 * to timeout issues.
 */
class TimeoutException implements Exception {
  final String message;

  const TimeoutException(this.message);

  String toString() => message;
}
