part of openreception.model;

class Channel {

  static const String NoID = '';

  String ID            = NoID;
  int    ownerUserID   = User.noID;
  String name          = '';
  String state         = '';
  String dialplanEntry = '';
}