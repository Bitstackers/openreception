part of openreception.model;

abstract class CalendarEntryChangeKey {
  static const String userID = 'uid';
  static const String updatedAt = 'updated';
  static const String username = 'username';
}

/**
 * Class representing a historic change, by a [User] in a [CalendarEntry].
 */
class CalendarEntryChange {

  int userID = User.nullID;
  DateTime changedAt;
  String username;

  /**
   * Default constructor.
   */
  CalendarEntryChange();

  /**
   * Deserializing constructor.
   */
  CalendarEntryChange.fromMap(Map map) {
    this.userID = map[CalendarEntryChangeKey.userID];
    this.changedAt = Util.unixTimestampToDateTime(map[CalendarEntryChangeKey.updatedAt]);
    this.username = map[CalendarEntryChangeKey.username];
  }

  /**
   * Returns a map representation of the object.
   * Suitable for serialization.
   */
  Map get asMap => {
    CalendarEntryChangeKey.userID : this.userID,
    CalendarEntryChangeKey.updatedAt : Util.dateTimeToUnixTimestamp(changedAt),
    CalendarEntryChangeKey.username : this.username
  };

  /**
   * Serialization function.
   */
  Map toJson() => this.asMap;
}