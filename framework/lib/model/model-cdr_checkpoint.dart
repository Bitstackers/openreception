part of openreception.model;

/**
 * A CDR checkpoint is a timespan which is used to delimit which CDR entries
 * should be included in a queried set.
 */
class CDRCheckpoint {
  DateTime start;
  DateTime end;
  String name;

  /**
   * Default empty constructor.
   */
  CDRCheckpoint.empty();

  /**
   * Deserializing constructor.
   */
  CDRCheckpoint.fromMap(Map map) {
    start = Util.unixTimestampToDateTime(map['start']);
    end   = Util.unixTimestampToDateTime(map['end']);
    name  = map['name'];
  }

  /**
   * JSON representation of the model class.
   */
  Map toJson() => {
    'start': Util.dateTimeToUnixTimestamp(start),
    'end'  : Util.dateTimeToUnixTimestamp(end),
    'name' : name
  };
}

/**
 * Comparator function.
 */
int compareCheckpoint(CDRCheckpoint c1, CDRCheckpoint c2) =>
  c1.end.compareTo(c2.end);

