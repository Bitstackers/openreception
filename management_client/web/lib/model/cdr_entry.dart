part of model;

class Cdr_Entry {
  double avgDuration;
  String billingType;
  int    callCount;
  int    duration;
  String flag;
  int    orgId;
  String orgName;
  int    smsCount;
  int    totalWait;

  Cdr_Entry.fromJson(Map json) {
    orgId       = json['org_id'];
    callCount   = json['call_count'];
    orgName     = json['org_name'];
    totalWait   = json['total_wait'];
    billingType = json['billing_type'];
    duration    = json['duration'];
    flag        = json['flag'];
    avgDuration = json['avg_duration'];

    //TODO Extract Data when the interface is updated.
    smsCount = 0;
  }
}
