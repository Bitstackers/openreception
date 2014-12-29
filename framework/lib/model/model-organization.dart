part of openreception.model;

abstract class OrganizationJSONKey {
  static const String BILLING_TYOE = 'billing_type';
  static const String FLAG = 'flag';
  static const String FULL_NAME = 'full_name';
  static const String ID = 'id';
}

class Organization {

  static const String className = '$libraryName.Organization';
  static final Logger log       = new Logger(Organization.className);
  static const int    noID      = 0;

  int    id          = noID;
  String fullName;
  String billingType;
  String flag;

  Organization.fromMap(Map organizationMap) {
    if (organizationMap == null) throw new ArgumentError('Null map');

    try {
      this
        ..id          = organizationMap[OrganizationJSONKey.ID]
        ..billingType = organizationMap[OrganizationJSONKey.BILLING_TYOE]
        ..flag        = organizationMap[OrganizationJSONKey.FLAG]
        ..fullName    = organizationMap[OrganizationJSONKey.FULL_NAME];
    } catch (error, stacktrace) {
      log.severe('Parsing of organization failed.', error, stacktrace);
      throw new ArgumentError('Invalid data in map');
    }

    this.validate();
  }

  /**
   * Returns a Map representation of the Organization.
   */
  Map get asMap =>
    {
    OrganizationJSONKey.ID: this.id,
    OrganizationJSONKey.BILLING_TYOE: this.billingType,
    OrganizationJSONKey.FLAG: this.flag,
    OrganizationJSONKey.FULL_NAME: this.fullName
    };

  void validate() {  }
}
