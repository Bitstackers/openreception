part of model;

class Colleague {
  int contactId;
  String contactName;
  bool contactEnabled;
  String contactType;

  Colleague(int this.contactId, String this.contactName, bool this.contactEnabled, String this.contactType);
}

class ReceptionColleague {
  int id;
  int organizationId;
  String fullName;
  bool enabled;

  List<Colleague> Colleagues = new List<Colleague>();

  ReceptionColleague(int this.id, int this.organizationId, String this.fullName, bool this.enabled);
}
