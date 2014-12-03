part of model;

class MessageList extends IterableBase<Message> {

  static const String className = "${libraryName}.MessageList";

  static final EventType reload = new EventType();
  static final EventType<int> add    = new EventType<int>();
  static final EventType<Message> stateChange = new EventType<Message>();

  EventBus _eventStream =  new EventBus();
  EventBus get events   => _eventStream;

  /// Singleton instance - for quick and easy reference.
  static MessageList _instance = new MessageList();
  static MessageList get instance => _instance;
  static set instance(MessageList newList) => _instance = newList;

  /// A set would have been a better fit here, but it makes the code read terrible.
  Map<int, Message> _map = new Map<int, Message>();

  /// Wrapped functions
  Map<int, Message> get values => this._map;
  bool contains (int MessageID) => this._map.containsKey(MessageID);

  /**
   * Iterator.
   *
   * This merely forwards the values from within the internal map.
   * We are not interested in the keys (Message ID) as they are already stored inside
   * the Message object.
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
    this._map[message.ID] = message;
  }


  void registerObservers () {
    const String context = '${className}.registerObservers';

    event.bus.on(Service.EventSocket.messageCreated).listen((Map event) {
      //TODO: invalidate cache.
      //storage.Contact.invalidateCalendar(calendarEvent['contactID'], calendarEvent['receptionID']);
      log.debugContext('Notifying about new message ${event}', context);
      this._eventStream.fire(add, event['message']['id']);
    });
  }


  /**
   * Reloads the MessageList from a List of Maps.
   *
   * TODO: Document the map format in the wiki.
   */
  MessageList.fromList (List<ORModel.Message> messages) {
    const String context = '${className}.fromList';

    try {
      messages.forEach((ORModel.Message message) {
        this.updateOrInsert(new Message.fromMap(message.asMap));
      });
    } catch (error, stacktrace) {
      log.criticalError(error, context);
      print(stacktrace);
      throw(error);
    }
  }

  /**
   * Reloads the MessageList from a List of Message.
   *
   * TODO: Document the map format in the wiki.
   */
  MessageList.fromMessageMap (Iterable<Message> messages) {
    messages.forEach((Message message) => this.updateOrInsert(message));
  }

  MessageList._internal();

  /**
   * Reloads the instance from the server
   *
   * Returns a Future containing the [MessageList] instance - updated with new elements.
   */
  Future<MessageList> reloadFromServer() {
    return Service.Message.instance.list().then ((List<ORModel.Message> messages){
      messages.forEach((Message message) => this.updateOrInsert(message));

      this._eventStream.fire(MessageList.reload, null);
      return this;
    });
  }
}
