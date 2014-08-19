part of model;

class ReceptionContact {
  int contactId;
  String fullName;
  String contactType;
  bool contactEnabled;
  int receptionId;
  bool wantsMessages;
  Map attributes;
  bool receptionEnabled;
  List<Map> phonenumbers;

  ReceptionContact.empty();

  ReceptionContact (
    int this.contactId,
    String this.fullName,
    String this.contactType,
    bool this.contactEnabled,
    int this.receptionId,
    bool this.wantsMessages,
    Map this.attributes,
    bool this.receptionEnabled,
    List this.phonenumbers);
}
