part of model;

class Reception extends ORModel.Reception implements Comparable<Reception> {
  List<Contact> contacts;
  int id;

  Reception() : super.empty();

  @override
  int compareTo(Reception other) => this.fullName.compareTo(other.fullName);
}
