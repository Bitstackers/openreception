library openreception.utilities;

int dateTimeToUnixTimestamp(DateTime time) {
  return time.toUtc().millisecondsSinceEpoch~/1000;
}

DateTime unixTimestampToDateTime(int secondsSinceEpoch) {
  return new DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch*1000, isUtc: true);
}
