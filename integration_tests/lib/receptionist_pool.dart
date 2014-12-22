part of or_test_fw;

class ReceptionistPool extends Pool<Receptionist>{

  static ReceptionistPool instance = null;

  ReceptionistPool(Iterable<Receptionist> elements) : super (elements);
}

