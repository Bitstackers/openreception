part of model;

class Cdr_Entry {
  int orgId;
  int callCount;
  String orgName;
  int totalWait;
  String billType;
  int duration;
  String flag;
  int smsCount;
  double avgDuration;

  Cdr_Entry();

  factory Cdr_Entry.fromJson(Map json) {
    Cdr_Entry object = new Cdr_Entry();
    object
      ..orgId = json['org_id']
      ..callCount = json['call_count']
      ..orgName = json['org_name']
      ..totalWait = json['total_wait']
      ..billType = json['bill_type']
      ..duration = json['duration']
      ..flag = json['flag']
      ..avgDuration = json['avg_duration'];

    //TODO Extract Data when the interface is updated.
    object.smsCount = 0;

    return object;
  }
}
