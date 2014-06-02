part of adaheads_server_model;

class Reception {
  int id;
  int organizationId;
  String fullName;
  Map attributes;
  String extradatauri;
  bool enabled;
  String receptionNumber;

  Reception(int this.id,
      int this.organizationId,
      String this.fullName,
      Map this.attributes,
      String this.extradatauri,
      bool this.enabled,
      String this.receptionNumber);
}
