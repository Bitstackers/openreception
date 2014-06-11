part of adaheads_server_model;

class CompleteReceptionContact {
  int id;
  String fullName;
  String contactType;
  bool contactEnabled;
  int receptionId;
  bool wantsMessages;
  Map attributes;
  bool receptionEnabled;
  List phonenumbers;

  CompleteReceptionContact (
    int this.id,
    String this.fullName,
    String this.contactType,
    bool this.contactEnabled,
    int this.receptionId,
    bool this.wantsMessages,
    Map this.attributes,
    bool this.receptionEnabled,
    List this.phonenumbers);
}
