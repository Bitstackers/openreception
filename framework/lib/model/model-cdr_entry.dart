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

part of openreception.model;

/**
 * A CDR entry is a single Call Detail Record entry representing the flow and
 * information of a termniated call.
 *
 * TODO: Move keys to keys package.
 */
class CDREntry {
  double avgDuration;
  String billingType;
  int    callCount;
  int    duration;
  String flag;
  int    orgId;
  String orgName;
  int    smsCount;
  int    totalWait;

  /**
   * Default empty constructor.
   */
  CDREntry.empty();

  /**
   * Deserializing constructor.
   */
  CDREntry.fromJson(Map json) {
    orgId       = json['org_id'];
    callCount   = json['call_count'];
    orgName     = json['org_name'];
    totalWait   = json['total_wait'];
    billingType = json['billing_type'];
    duration    = json['duration'];
    flag        = json['flag'];
    avgDuration = json['avg_duration'];

    //TODO Extract Data when the interface is updated.
    smsCount = -1;
  }
}
