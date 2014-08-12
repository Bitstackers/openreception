part of openreception.storage;

abstract class MessageQueue {

  Future <Model.MessageQueueItem> save (Model.MessageQueueItem queueItem);

  Future <List<Model.MessageQueueItem>> list ({int limit : 100});
}