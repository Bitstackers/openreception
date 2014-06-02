part of adaheads_server_model;

class Phone {
  int id;
  String value;
  String kind;
  String description;
  String bill_type; //Landline, mobile, which foreign country
  bool confidential;

  Phone(int this.id, String this.value, String this.kind, String this.description, String this.bill_type, bool this.confidential);
}
