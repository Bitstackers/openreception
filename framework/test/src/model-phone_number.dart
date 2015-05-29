part of openreception.test;

void testModelPhoneNumber() {
  group('Model.PhoneNumber', () {
    test('buildObject', ModelPhoneNumber.buildObject);
  });
}

abstract class ModelPhoneNumber {
  static void buildObject () {
    final String description =  'Cell Phone - work';
    final String value = '+45 44 88 1231';
    final String type = 'pstn';
    final bool confidential = false;
    final String billing_type = 'cell';
    final List<String> tags = ['work', 'official'];


    Model.PhoneNumber phoneNumber =
      new Model.PhoneNumber.empty()
        ..billing_type = billing_type
        ..confidential = confidential
        ..description = description
        ..tags = tags
        ..type = type
        ..value = value;

    expect (phoneNumber.billing_type, equals(billing_type));
    expect (phoneNumber.confidential, equals(confidential));
    expect (phoneNumber.description, equals(description));
    expect (phoneNumber.tags, equals(tags));
    expect (phoneNumber.type, equals(type));
    expect (phoneNumber.value, equals(value));
  }
}