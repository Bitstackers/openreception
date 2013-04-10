part of logger;

class UserlogRecord {
  final DateTime time;
  final String message;

  UserlogRecord(this.message) :
    time = new DateTime.now();
}
