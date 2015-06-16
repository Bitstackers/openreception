part of openreception.storage;

abstract class CDR {

  Future<Iterable<Model.CDREntry>>listEntries(DateTime from, DateTime to);

  Future<Iterable<Model.CDRCheckpoint>> checkpoints();

  Future<Model.CDRCheckpoint> createCheckpoint(Model.CDRCheckpoint checkpoint);
}