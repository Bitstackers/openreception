part of openreception.model;

class CalendarEntry {

  static final String className = '${libraryName}.CalendarEntry';
  static final Logger log = new Logger(className);

  static const int noID = 0;

  String _content;
  DateTime _start;
  DateTime _stop;

  bool get active => _active();

  int _ID          = CalendarEntry.noID;
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

  Map toJson() => this.asMap;

  Map get asMap {
    Map map=  {
       'id'     : this.ID,
       'reception_id' : this.receptionID,
       'start'  : Util.dateTimeToUnixTimestamp(this._start),
       'stop'   : Util.dateTimeToUnixTimestamp(this._stop),
       'content': this._content
       };

    if (this.contactID != Contact.noID) {
      map['contact_id'] = this.contactID;
    }

    return map;
  }


  CalendarEntry();
  CalendarEntry.forContact(this._contactID, this._receptionID);
  CalendarEntry.forReception(this._receptionID);

  bool _active() {
    DateTime now = new DateTime.now();
    return (now.isAfter(_start) && now.isBefore(_stop));
  }

  /**
     * [CalendarEntry] constructor. Expects a map in the following format:
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
  CalendarEntry.fromMap(Map json) {
    this.._ID          = json['id']
        .._receptionID = json['reception_id']
        .._contactID   = json['contact_id'] != null ? json['contact_id'] : Contact.noID
        .._start       = Util.unixTimestampToDateTime(json['start'])
        .._stop        = Util.unixTimestampToDateTime(json['stop'])
        .._content     = json['content'];
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
     * Enables a [CalendarEntry] to sort itself compared to other calendar events.
     */
  int compareTo(CalendarEntry other) {
    if (_start.isAtSameMomentAs(other._start)) {
      return 0;
    }

    return _start.isBefore(other._start) ? 1 : -1;
  }

  /**
     * [CalendarEntry] as String, for debug/log purposes.
     */
  String toString() => 'start: ${this.start}, '
                       'stop: ${this.stop}, '
                       'rid: ${this.receptionID}, '
                       'cid: ${this.contactID}, '
                       'content: ${this.content}';
}
