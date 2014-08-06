part of model;

class CalendarEvent implements Comparable<CalendarEvent> {
  int      id;
  String   message;
  DateTime start;
  DateTime stop;

  CalendarEvent();

  CalendarEvent.fromJson(Map json) {
    id      = json['id'];
    start   = dateTimeFromUnixTimestamp(json['start']);
    stop    = dateTimeFromUnixTimestamp(json['stop']);
    message = json['content'];
  }

  Map toJson() => {
    'id'     : id,
    'start'  : unixTimestampFromDateTime(start),
    'stop'   : unixTimestampFromDateTime(stop),
    'content': message
  };

  @override
  int compareTo(CalendarEvent other) {
    int result = this.start.compareTo(other.start);
    return result == 0 ? this.stop.compareTo(other.stop) : result;
  }
}
