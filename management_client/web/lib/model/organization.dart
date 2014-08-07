part of model;

class Organization implements Comparable<Organization> {
  String billType;
  String flag;
  String fullName;
  int    id;

  Organization();

  Organization.fromJson(Map json) {
    billType = json['bill_type'];
    flag     = json['flag'];
    fullName = json['full_name'];
    id       = json['id'];
  }

  Map toJson() => {
    'bill_type': billType,
    'flag'     : flag,
    'full_name': fullName,
    'id'       : id
  };

  @override
  int compareTo(Organization other) => this.fullName.compareTo(other.fullName);
}
