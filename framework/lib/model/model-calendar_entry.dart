part of openreception.model;

class CalendarEntry {
  static final String className = '${libraryName}.CalendarEntry';
  static final Logger log       = new Logger(className);

  int              _contactID   = Contact.noID;
  String           _content;
  int              _ID          = CalendarEntry.noID;
  static const int noID         = 0;
  int              _receptionID = Reception.noID;
  DateTime         _start;
  DateTime         _stop;

  /**
   * Constructor.
   */
  CalendarEntry();

  /**
   * Constructor for [Contact] calendar entries.
   */
  CalendarEntry.forContact(this._contactID, this._receptionID);

  /**
   * Constructor for [Reception] calendar entries.
   */
  CalendarEntry.forReception(this._receptionID);

  /**
   * [CalendarEntry] constructor. Expects a map in the following format:
   *
   *  {
   *    'id'               : int entry id,
   *    'reception_id'     : int reception id,
   *    'contact_id'       : int contact id (optional),
   *    'start'            : DateTime String,
   *    'stop'             : DateTime String,
   *    'content'          : String,
   *    'last_modified'    : DateTime String,
   *    'last_modified_by' : int user id
   *  }
   *
   *  'start' and 'stop' MUST be in a format that can be parsed by the
   *  [DateTime.parse] method. 'content' is the actual event description.
   */
  CalendarEntry.fromMap(Map json) {
    _ID              = json['id'];
    _receptionID     = json['reception_id'];
    _contactID       = json['contact_id'] != null ? json['contact_id'] : Contact.noID;
    _start           = Util.unixTimestampToDateTime(json['start']);
    _stop            = Util.unixTimestampToDateTime(json['stop']);
    _content         = json['content'];
  }

  bool _active() {
    DateTime now = new DateTime.now();
    return (now.isAfter(_start) && now.isBefore(_stop));
  }

  /**
   * Return true if now is between after [start] and before [stop].
   */
  bool get active => _active();

  Map get asMap =>
      {'id'               : ID,
       'contact_id'       : contactID != Contact.noID ? contactID : null,
       'reception_id'     : receptionID,
       'start'            : Util.dateTimeToUnixTimestamp(start),
       'stop'             : Util.dateTimeToUnixTimestamp(stop),
       'content'          : content
      };

  /**
   * The calendar entry starts at [start].
   */
  void set beginsAt(DateTime start) {
    _start = start;
  }

  /**
   * Return the contact id for this calendar entry. MAY be [Contact.noID] if
   * this is a reception only entry.
   */
  int get contactID => _contactID;

  /**
   * Get the actual calendar entry text content.
   */
  String get content => _content;

  /**
   * Set the calendar entry text content.
   */
  void set content(String eventBody) {
    _content = eventBody;
  }

  int get ID => _ID;

  void set ID(int newID) {
    _ID = newID;
  }

  int get receptionID => _receptionID;

  /**
   * When this calendar entry begins.
   */
  DateTime get start => _start;

  /**
   * When this calendar entry ends.
   */
  DateTime get stop => _stop;

  Map toJson() => asMap;

  /**
   * [CalendarEntry] as String, for debug/log purposes.
   */
  String toString() => 'start: ${start.toIso8601String()}, '
                       'stop: ${stop.toIso8601String()}, '
                       'rid: ${receptionID}, '
                       'cid: ${contactID}, '
                       'content: ${content}';

  /**
   * The calendar entry ends at [stop].
   */
  void set until(DateTime stop) {
    _stop = stop;
  }
}
