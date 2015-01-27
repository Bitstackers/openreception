part of openreception.model;

class CalendarEvent implements Comparable {

  static const int noID = 0;

  String _content;
  DateTime _start;
  DateTime _stop;


  bool get active => new DateTime.now().isAfter(this.stopTime);

  int _ID          = CalendarEvent.noID;
  int _contactID   = Contact.noID;
  int _receptionID = Reception.noID;

  int get ID => this._ID;

  void set ID(int newID) {
    this._ID = newID;
  }

  String get start => _formatTimestamp(this.startTime);
  String get stop  => _formatTimestamp(this.stopTime);
  DateTime get startTime => this._start;
  DateTime get stopTime => this._stop;
  String get content => this._content;
  int get contactID => this._contactID;
  int get receptionID => this._receptionID;

  void set beginsAt(DateTime start) {
    this._start = start;
  }

  void set until(DateTime stop) {
    this._stop = stop;
  }

  void set content(String eventBody) {
    this._content = eventBody;
  }

  CalendarEvent.forContact(this._contactID, this._receptionID);

  CalendarEvent.forReception(this._receptionID);

  Map toJson() => this.asMap;


  Map get asMap =>
  {
    'id': this.ID,
    'start': _timeToEpoch(this._start),
    'stop': _timeToEpoch(this._stop),
    'content': this._content
  };

  //TODO: check time implementation with the one from util.
  static int _timeToEpoch(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;

  CalendarEvent();

  /**
     * [CalendarEvent] constructor. Expects a map in the following format:
     *
     *  {
     *    'start'   : DateTime String,
     *    'stop'    : DateTime String,
     *    'content' : String
     *  }
     *
     *  'start' and 'stop' MUST be in a format that can be parsed by the
     *  [DateTime.parse] method. 'content' is the actual event description.
     */
  CalendarEvent.fromMap(Map json, int receptionID, {int contactID : Contact.noID}) {
    this._ID = json['id'];
    this._receptionID = receptionID;
    this._contactID = contactID;
    this._start = DateTime.parse(json['start']);
    this._stop = DateTime.parse(json['stop']);
    this._content = json['content'];
  }

  /**
     * Format the [DateTime] [stamp] timestamp into a string. If [stamp] is today
     * then return hour:minute, else return day/month hour:minute. Append year if
     * [stamp] is in another year than now.
     */
  String _formatTimestamp(DateTime stamp) {
    final String day = new DateFormat.d().format(stamp);
    final String hourMinute = new DateFormat.Hm().format(stamp);
    final String month = new DateFormat.M().format(stamp);
    final DateTime now = new DateTime.now();
    final StringBuffer output = new StringBuffer();
    final String year = new DateFormat.y().format(stamp);

    if (new DateFormat.yMd().format(stamp) != new DateFormat.yMd().format(now)) {
      output.write('${day}/${month}');
    }

    if (new DateFormat.y().format(stamp) != new DateFormat.y().format(now)) {
      output.write('/${year.substring(2)}');
    }

    output.write(' ${hourMinute}');

    return output.toString();
  }

  /**
     * Enables a [CalendarEvent] to sort itself compared to other calendar events.
     */
  int compareTo(CalendarEvent other) {
    if (_start.isAtSameMomentAs(other._start)) {
      return 0;
    }

    return _start.isBefore(other._start) ? 1 : -1;
  }

  /**
     * [CalendarEvent] as String, for debug/log purposes.
     */
  String toString() => 'start: ${this.start}, '
                       'stop: ${this.stop}, '
                       'rid: ${this.receptionID}, '
                       'cid: ${this.contactID}, '
                       'content: ${this.content}';
}
