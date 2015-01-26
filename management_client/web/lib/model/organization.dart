part of model;

class Organization implements Comparable<Organization> {
  String billingType;
  String flag;
  String fullName;
  int    id;

  Organization.fromJson(Map json) {
    billingType = json[ORF.OrganizationJSONKey.BILLING_TYPE];
    flag        = json[ORF.OrganizationJSONKey.FLAG];
    fullName    = json[ORF.OrganizationJSONKey.FULL_NAME];
    id          = json[ORF.OrganizationJSONKey.ID];
  }

  Map toJson() => {
    ORF.OrganizationJSONKey.BILLING_TYPE: billingType,
    ORF.OrganizationJSONKey.FLAG        : flag,
    ORF.OrganizationJSONKey.FULL_NAME   : fullName,
    ORF.OrganizationJSONKey.ID          : id
  };

  @override
  int compareTo(Organization other) => this.fullName.compareTo(other.fullName);
}
