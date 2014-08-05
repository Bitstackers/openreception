part of model;

class CalendarEvent {
  int id;
  DateTime start;
  DateTime stop;
  String message;

  CalendarEvent();

  factory CalendarEvent.fromJson(Map json) {
    CalendarEvent object = new CalendarEvent()
      ..id = json['id']
      ..start = new DateTime.fromMillisecondsSinceEpoch(json['start']*1000)
      ..stop = new DateTime.fromMillisecondsSinceEpoch(json['stop']*1000)
      ..message = json['content'];

    return object;
  }

  Map toJson() {
    Map data = {
      'id': id,
      'start': start.millisecondsSinceEpoch~/1000,
      'stop': stop.millisecondsSinceEpoch~/1000,
      'content': message
    };

    return data;
  }

  static int sortByStartThenStop(CalendarEvent a, CalendarEvent b) {
    int result = a.start.compareTo(b.start);
    if(result == 0) {
      return a.stop.compareTo(b.stop);
    } else {
      return result;
    }
  }
}
