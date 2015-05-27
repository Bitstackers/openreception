part of openreception.model;

abstract class CalendarEntryChangeKey {
  static const String userID = 'uid';
  static const String updatedAt = 'updated';
  static const String username = 'username';
}

class CalendarEntryChange {

  int userID = User.nullID;
  DateTime changedAt;
  String username;

  CalendarEntryChange();

  CalendarEntryChange.fromMap(Map map) {
    this.userID = map[CalendarEntryChangeKey.userID];
    this.changedAt = Util.unixTimestampToDateTime(map[CalendarEntryChangeKey.updatedAt]);
    this.username = map[CalendarEntryChangeKey.username];
  }

  Map get asMap => {
    CalendarEntryChangeKey.userID : this.userID,
    CalendarEntryChangeKey.updatedAt : Util.dateTimeToUnixTimestamp(changedAt),
    CalendarEntryChangeKey.username : this.username
  };

  Map toJson() => this.asMap;
}