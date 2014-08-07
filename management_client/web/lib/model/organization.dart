part of model;

class Organization implements Comparable<Organization> {
  String billingType;
  String flag;
  String fullName;
  int    id;

  Organization.fromJson(Map json) {
    billingType = json['billing_type'];
    flag     = json['flag'];
    fullName = json['full_name'];
    id       = json['id'];
  }

  Map toJson() => {
    'billing_type': billingType,
    'flag'     : flag,
    'full_name': fullName,
    'id'       : id
  };

  @override
  int compareTo(Organization other) => this.fullName.compareTo(other.fullName);
}
