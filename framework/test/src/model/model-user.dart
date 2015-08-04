part of openreception.test;

testModelUser() {
  group('Model.User', () {
    test('serialization', ModelUser.serialization);

    test('deserialization', ModelUser.deserialization);

    test('buildObject', ModelUser.buildObject);

    test('decodeMap', ModelUser.decodeMap);
  });
}

abstract class ModelUser {

  static void decodeMap() {
    Model.User decodedObject = new Model.User.fromMap (Test_Data.userMap);

    expect(decodedObject, isNotNull);
    expect(decodedObject.identities, isNotEmpty);
    expect(decodedObject.groups, isNotEmpty);
  }

  static void serialization() {
    Model.User builtObject = buildObject();
    String serializedString = JSON.encode(builtObject);

    expect(serializedString, isNotEmpty);
    expect(serializedString, isNotNull);
  }

  static void deserialization() {
    Model.User builtObject = buildObject();
    String serializedString = JSON.encode(builtObject);
    Model.User deserializedObject =
        new Model.User.fromMap(JSON.decode(serializedString));

    expect(builtObject.ID, equals(deserializedObject.ID));
    expect(builtObject.address, equals(deserializedObject.address));
    expect(builtObject.googleAppcode, equals(deserializedObject.googleAppcode));
    expect(
        builtObject.googleUsername, equals(deserializedObject.googleUsername));
    expect(builtObject.identities, equals(deserializedObject.identities));
    expect(builtObject.groups, equals(deserializedObject.groups));
    expect(builtObject.name, equals(deserializedObject.name));
    expect(builtObject.peer, equals(deserializedObject.peer));
  }

  static Model.User buildObject() {
    final int userID = 2;
    final String address = 'golden@fish.net';
    final String gmail = 'golden@sea-mail.net';
    final String appcode = 'buford';
    final String name = 'Biff, the gold fish';
    final String peer = 'Hidden underneath';
    final String picture = 'too_revealing.png';

    final List<Model.UserGroup> groups =
        [new Model.UserGroup.empty()
          ..id = 4
          ..name = 'Sea-dweller',
         new Model.UserGroup.empty()
          ..id = 3
          ..name = 'Fish'];

    final List<Model.UserIdentity> identities =
        [new Model.UserIdentity.empty()
          ..userId = userID
          ..identity = 'biff@sharkbait',
         new Model.UserIdentity.empty()
          ..userId = userID
          ..identity = address];

    Model.User builtObject = new Model.User.empty()
      ..ID = userID
      ..address = address
      ..googleUsername = gmail
      ..googleAppcode = appcode
      ..groups = groups
      ..identities = identities
      ..name = name
      ..peer = peer
      ..portrait = picture;

    expect(builtObject.ID, equals(userID));
    expect(builtObject.address, equals(address));
    expect(builtObject.googleAppcode, equals(appcode));
    expect(builtObject.googleUsername, equals(gmail));
    expect(builtObject.identities, equals(identities));
    expect(builtObject.groups, equals(groups));
    expect(builtObject.name, equals(name));
    expect(builtObject.peer, equals(peer));
    expect(builtObject.portrait, equals(picture));

    return builtObject;
  }
}
