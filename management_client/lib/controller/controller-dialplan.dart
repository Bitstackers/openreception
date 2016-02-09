part of management_tool.controller;


class Dialplan {

  final ORService.RESTDialplanStore _dpStore;

  Dialplan(this._dpStore);

  Future<Iterable<ORModel.DialplanTemplate>> getTemplates() => throw new UnimplementedError();

  Future<libdialplan.Dialplan> getDialplan(int receptionId) => throw new UnimplementedError();

  Future markDialplanAsCompiled(int receptionId) => throw new UnimplementedError();

  Future<Iterable<ORModel.Playlist>> getPlaylistList() => throw new UnimplementedError();

  Future<ivr.IvrList> getIvr(int receptionId) => throw new UnimplementedError();

  Future updateDialplan (int receptionId, libdialplan.Dialplan dp)  => throw new UnimplementedError();
  Future updateIvr (int receptionId, ivr.IvrList ivr)  => throw new UnimplementedError();

  Future<Iterable<ORModel.Audiofile>> getAudiofileList (int receptionId)  => throw new UnimplementedError();


  ///Playlist-stuff
  Future<ORModel.Playlist> getPlaylist(int id)  => throw new UnimplementedError();
  Future recordSoundFile(int receptionId, String filename) => throw new UnimplementedError();
  Future deleteSoundFile(int receptionId, String filename) => throw new UnimplementedError();

  Future deletePlaylist(int id) => throw new UnimplementedError();

  Future createPlaylist(ORModel.Playlist pl) => throw new UnimplementedError();
  Future updatePlaylist(ORModel.Playlist pl) => throw new UnimplementedError();

}
