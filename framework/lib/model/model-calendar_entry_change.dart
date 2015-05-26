part of openreception.model;

abstract class CalendarEntryChangeKey {
  static const String userID = 'uid';
  static const String updatedAt = 'updated';
}

class CalendarEntryChange {

  int userID = User.nullID;
  DateTime changedAt;

  CalendarEntryChange();

  CalendarEntryChange.fromMap(Map map) {
    this.userID = map[CalendarEntryChangeKey.userID];
    this.changedAt = Util.unixTimestampToDateTime(map[CalendarEntryChangeKey.updatedAt]);
  }

  Map get asMap => {
    CalendarEntryChangeKey.userID : this.userID,
    CalendarEntryChangeKey.updatedAt : Util. dateTimeToUnixTimestamp(changedAt)
  };

  Map toJson() => this.asMap;
}