library openreception.utilities;

int dateTimeToUnixTimestamp(DateTime time) {
  return time.toUtc().millisecondsSinceEpoch~/1000;
}

DateTime unixTimestampToDateTime(int secondsSinceEpoch) {
  return new DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch*1000, isUtc: true);
}

String removeTailingSlashes (Uri host) {
   String _trimmedHostname = host.toString();

   while (_trimmedHostname.endsWith('/')) {
     _trimmedHostname = _trimmedHostname.substring(0, _trimmedHostname.length-1);
   }

   return _trimmedHostname;
}