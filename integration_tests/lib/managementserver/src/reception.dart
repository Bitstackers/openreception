part of or_test_fw;

class _reception {
  static Transport.Client client;
  static Storage.Reception receptionStore;

  static Future getReception() {
    const int receptionId = 1;

    return receptionStore.get(receptionId).then((Model.Reception reception) {
      expect(reception.ID, equals(receptionId));
      expect(reception.fullName, isNotEmpty);
      expect(reception.greeting, isNotEmpty);
    });
  }

  static Future getNonExistingReception() {
    const int organizationId = 999999999;
    return receptionStore.get(organizationId).then((Model.Reception reception) {
      fail('This should have returned a NOT FOUND');
    }).catchError((error) {
      expect(error, new isInstanceOf<Storage.NotFound>());
    });
  }

  static Future getReceptionList() {
    return receptionStore.list().then((List<Model.Reception> receptions) {
      expect(receptions, isNotNull);
      receptions.forEach((r) => expect(r.ID, greaterThanOrEqualTo(1)));
    });
  }

  static Future updateReception() {
    const int receptionId = 1;

    return receptionStore.get(receptionId).then((Model.Reception reception) {
      expect(reception, isNotNull);
      String originale_full_name = reception.fullName;
      String new_full_name = 'Test-Update ${originale_full_name}';
      reception.fullName = new_full_name;

      return receptionStore.update(reception).then((Model.Reception updatedReception) {
        expect(updatedReception.fullName, equals(new_full_name));

        //Roll-back
        updatedReception.fullName = originale_full_name;
        return receptionStore.update(updatedReception);
      });
    });
  }

  static Future createReception() {
    const String full_name = '..Test-Create Mandela A/S';
    const String shortGreeting = 'Welcome to this wonderfull land.';
    const String greeting = 'cash';
    const int organization_id = 1;

    Model.Reception reception = new Model.Reception.empty()
      ..organizationId = organization_id
      ..fullName = full_name
      ..shortGreeting = shortGreeting
      ..greeting = greeting
      ..enabled = false;

    return receptionStore.create(reception).then((Model.Reception newReception) {
      expect(newReception.organizationId, equals(organization_id));
      expect(newReception.ID, greaterThanOrEqualTo(1));
      expect(newReception.fullName, equals(full_name));
      expect(newReception.shortGreeting, equals(shortGreeting));
      expect(newReception.greeting, equals(greeting));

      //Clean up.
      return receptionStore.remove(newReception.ID);
    });
  }
}