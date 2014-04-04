part of messageserver.database;

class Messaging_Contact {
  int contact_ID;
  int reception_ID;
  String role;
   
  DateTime sometime = new DateTime;
  
  Messaging_Contact (String contact_reception, String role) {
    List<String> split = contact_reception.split('@');
    this.contact_ID = int.parse(split[0]);
    this.reception_ID = int.parse(split[1]);
    this.role = role;
  }
  
  int get hashCode {
    return (this.ContactString()).hashCode;
  }
  
  bool operator == (Messaging_Contact other) {
    return this.ContactString() == other.ContactString();
  }
  
  String ContactString() {
    return contact_ID.toString() + "@" + reception_ID.toString(); 
  }
}
