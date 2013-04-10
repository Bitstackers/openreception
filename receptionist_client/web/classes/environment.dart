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

/**
 * Contains the current state of Bob.
 */
library environment;

import 'dart:async';

import 'package:web_ui/web_ui.dart';

import 'common.dart';
import 'context.dart';
import 'logger.dart';
import 'model.dart';

/**
 * Environment singletons.
 */
final _ContextList contextList = new _ContextList();
final _Environment environment = new _Environment();

/**
 * The application contexts. Contexts can be added and the list can be iterated,
 * but contexts cannot be removed or the list cleared.
 */
class _ContextList extends Iterable<Context>{
  List<Context> list = toObservable(new List<Context>());

  _ContextList();

  void add(Context context) {
    list.add(context);
  }

  void decreaseAlert(String contextId) {
    list.forEach((context) {
      if (contextId == context.id) { // ???? Master Joda. 2 == context.id
        context.decreaseAlert();
      }
    });
  }

  void increaseAlert(String contextId) {
    list.forEach((context) {
      if (contextId == context.id) {
        context.increaseAlert();
      }
    });
  }

  Iterator<Context> get iterator => new GenericListIterator<Context>(list);
}

/**
 * Environment data. This contains data that is shared across the entire
 * application, such as the currently active organization, current active call
 * and similar.
 */
class _Environment{
  _Environment();

  /*
     Organization
  */
  var _organizationStream = new StreamController<Organization>.broadcast();
  Stream<Organization> get onOrganizationChange => _organizationStream.stream;

  Organization _organization;
  Organization get organization => _organization;

 /**
  * Replaces this environments organization with [organization].
  */
  void setOrganization(Organization organization) {
    if (organization == _organization) {
      return;
    }

    _organization = organization;
    log.info('Environment organization is changed to: ${organization.toString()}');
    //dispatch the new organization.
    _organizationStream.sink.add(organization);
  }

  /*
     Call
  */
  var callStream = new StreamController<Call>.broadcast();

  Call _call;
  Call get call => _call;

  /**
   * Subscribe to call changes.
   */
  void onCallChange(CallSubscriber subscriber){
    callStream.stream.listen(subscriber);
  }

 /**
  * Replaces this environments call with [call].
  */
  void setCall(Call call) {
    if (call == _call) {
      return;
    }
    _call = call;
    log.info('The current call is changed to: ${call.toString()}');
    //dispatch the new call.
    callStream.sink.add(call);
  }
}
