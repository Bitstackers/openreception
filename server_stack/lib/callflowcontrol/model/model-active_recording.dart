part of openreception.call_flow_control_server.model;


class ActiveRecordings extends IterableBase {

  static final instance = new ActiveRecordings();

  Logger _log = new Logger ('$libraryName.ActiveRecordings');

  Map _recordings = {};

  /**
   * Handle an incoming [ESL.Event] packet
   */
  void handleEvent(ESL.Event packet) {

    void dispatch() {
      switch (packet.eventName) {
        case (PBXEvent.RECORD_START):
          final String uuid = packet.field('Unique-ID');
          final String path = 'Record-File-Path';

          log.finest('Starting recording of channel $uuid at path $path');
          _recordings[uuid] = path;

          break;

        case (PBXEvent.RECORD_STOP):
          final String uuid = packet.field('Unique-ID');
          final String path = 'Record-File-Path';

          log.finest('Stopping recording of channel $uuid at path $path');
          _recordings.remove(uuid);

          break;
      }
    }

    try {
      dispatch();
    } catch (error, stackTrace) {
      _log.severe('Failed to dispatch ${packet.eventName}');
      _log.severe(error, stackTrace);
    }
  }

}