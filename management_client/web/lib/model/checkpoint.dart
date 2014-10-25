part of model;

class Checkpoint implements Comparable<Checkpoint>{
  DateTime start;
  DateTime end;
  String name;

  Checkpoint();

  Checkpoint.fromJson(Map json) {
    start = dateTimeFromUnixTimestamp(json['start']);
    end   = dateTimeFromUnixTimestamp(json['end']);
    name  = json['name'];
  }

  @override
  int compareTo(Checkpoint other) {
    int endCompare = this.end.compareTo(other.end);
    return endCompare != 0 ? endCompare : this.start.compareTo(other.start);
  }

  Map toJson() => {
    'start': unixTimestampFromDateTime(start),
    'end'  : unixTimestampFromDateTime(end),
    'name' : name
  };
}

DateTime dateTimeFromUnixTimestamp(int seconds) => new DateTime.fromMillisecondsSinceEpoch(seconds*1000);

int unixTimestampFromDateTime(DateTime datetime) => datetime.millisecondsSinceEpoch~/1000;
