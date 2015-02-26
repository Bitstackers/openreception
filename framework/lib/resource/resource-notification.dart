part of openreception.resource;

abstract class Notification {
  static final broadcast    = "/broadcast";
  static final message      = "/message";

  static Uri notifications(Uri host)
      => Uri.parse('${host}/notifications');

  static Uri notification(Uri host)
      => Uri.parse('${host}/notification');
}