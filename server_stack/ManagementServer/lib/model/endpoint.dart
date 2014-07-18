part of adaheads_server_model;

class Endpoint {
  int contactId;
  int receptionId;
  String address;
  String addressType;
  bool confidential;
  bool enabled;
  int priority;

  Endpoint(int    this.contactId,
           int    this.receptionId,
           String this.address,
           String this.addressType,
           bool   this.confidential,
           bool   this.enabled,
           int    this.priority);
}
