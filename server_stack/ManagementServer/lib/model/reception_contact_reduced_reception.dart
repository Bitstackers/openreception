part of adaheads_server_model;

class ReceptionContact_ReducedReception {
  int contactId;
  bool wantsMessages;
  Map attributes;
  bool contactEnabled;
  List phoneNumbers;

  int receptionId;
  bool receptionEnabled;
  String receptionName;

  int organizationId;

  ReceptionContact_ReducedReception (
    int this.contactId,
    bool this.wantsMessages,
    Map this.attributes,
    bool this.contactEnabled,
    List this.phoneNumbers,

    int this.receptionId,
    String this.receptionName,
    bool this.receptionEnabled,

    int this.organizationId);
}
