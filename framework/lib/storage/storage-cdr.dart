part of openreception.storage;

abstract class CDR {

  Future<Iterable<Model.CDREntry>>listEntries();

  Future<Iterable<Model.CDRCheckpoint>> checkpoints();

  Future<Model.CDRCheckpoint> createCheckpoint();
}