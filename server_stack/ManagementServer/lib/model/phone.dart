part of model;

class Phone {
  int id;
  String value;
  String kind;
  String description;
  String billingType; //Landline, mobile, which foreign country
  bool confidential;

  Phone(int this.id, String this.value, String this.kind, String this.description, String this.billingType, bool this.confidential);
}
