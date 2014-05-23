part of model;

class MessageList extends IterableBase<Message> {

  static const String className = "${libraryName}.MessageList";

  static final EventType reload = new EventType();
  static final EventType<Message> stateChange = new EventType<Message>();

  EventBus _eventStream =  new EventBus();
  EventBus get events   => _eventStream;

  /// Singleton instance - for quick and easy reference.
  static MessageList _instance = new MessageList();
  static MessageList get instance => _instance;
  static set instance(MessageList newList) => _instance = newList;

  /// A set would have been a better fit here, but it makes the code read terrible.
  Map<int, Message> _map = new Map<int, Message>();

  /**
   * Iterator. 
   * 
   * This merely forwards the values from within the internal map.
   * We are not interested in the keys (Peer ID) as they are already stored inside
   * the Peer Object.
   */
  Iterator<Message> get iterator => this._map.values.iterator;

  /**
   * Default constructor.
   */
  MessageList();
  
  /**
   * Updates or inserts a [Message] object into the [MessageList]. 
   */
  void updateOrInsert(Message message) {
    const String context = '${className}.update'; 
    
    if (this._map.containsKey(message.ID)) {
      log.debugContext("Updating peer ${message.ID}", context);
      this._map[message.ID].update(message);
    } else {
      log.debugContext("Inserting peer ${message.ID}", context);
      this._map[message.ID] = message;
    }
  }
  
  /**
   * Reloads the MessageList from a List of Maps.
   * 
   * TODO: Document the map format in the wiki.
   */
  MessageList.fromList (List<Map> messageMaps) {
    const String context = '${className}.fromList'; 
    
    try {
      messageMaps.forEach((Map messageMap) {
        this.updateOrInsert(new Message.fromMap(messageMap));
      });
    } catch (error) {
      log.criticalError(error, context);
      throw(error);
    }
  }
  
  /**
   * Reloads the instance from the server
   * 
   * Returns a Future containing the [MessageList] instance - updated with new elements.
   */
  Future<MessageList> reloadFromServer() {
    return Service.Message.list().then ((MessageList messageList){
      this._map = messageList._map;
      
      this._eventStream.fire(MessageList.reload, null);
      return this;
    });
  }
}
