part of or_test_fw;

class ReceptionistPool extends Pool<Receptionist>{

  static ReceptionistPool instance = null;

  ReceptionistPool(Iterable<Receptionist> elements) : super (elements);

  Future initialized () =>
      Future.forEach(this.elements, (Receptionist r) => r.ready());
}

