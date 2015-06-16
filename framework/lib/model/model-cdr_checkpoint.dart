part of openreception.model;

/**
 *
 */
class CDRCheckpoint {
  DateTime start;
  DateTime end;
  String name;

  /**
   *
   */
  CDRCheckpoint.empty();

  /**
   *
   */
  CDRCheckpoint.fromJson(Map json) {
    start = Util.unixTimestampToDateTime(json['start']);
    end   = Util.unixTimestampToDateTime(json['end']);
    name  = json['name'];
  }

  /**
   *
   */
  Map toJson() => {
    'start': Util.dateTimeToUnixTimestamp(start),
    'end'  : Util.dateTimeToUnixTimestamp(end),
    'name' : name
  };
}

/**
 *
 */
int compareCheckpoint(CDRCheckpoint c1, CDRCheckpoint c2) =>
  c1.end.compareTo(c2.end);

