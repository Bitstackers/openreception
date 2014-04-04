part of messageserver.database;

class MessageList extends Set<Message> {
  int userID;
  
  factory fromDatabase (int userID, int lowerLimit, int upperLimit) {
    
  }
}


