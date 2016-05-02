/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.call_flow_control_server.model;

/**
 * Holds a list of currently active recordings based on events from FreeSWITCH.
 */
class ActiveRecordings extends IterableBase<ORModel.ActiveRecording> {
  /// Singleton instance.
  static final instance = new ActiveRecordings();

  ///Internal logger.
  Logger _log = new Logger('$libraryName.ActiveRecordings');

  /**
   * Active recordings are, internally, stored as maps to enable easy lookup.
   */
  Map<String, ORModel.ActiveRecording> _recordings = {};

  /// Interator simply forwards the values of the map in no particular order.
  Iterator<ORModel.ActiveRecording> get iterator => _recordings.values.iterator;

  /**
   * Retrive a specific recording identified by its channel [uuid].
   */
  ORModel.ActiveRecording get(String uuid) => _recordings.containsKey(uuid)
      ? _recordings[uuid]
      : throw new ORStorage.NotFound('No active recordings on uuid');

  /**
   * Handle an incoming [ESL.Event] packet
   */
  void handleEvent(ESL.Event packet) {
    void dispatch() {
      switch (packet.eventName) {
        case (PBXEvent.recordStart):
          final String uuid = packet.field('Unique-ID');
          final String path = packet.field('Record-File-Path');

          log.finest('Starting recording of channel $uuid at path $path');
          _recordings[uuid] = new ORModel.ActiveRecording(uuid, path);

          break;

        case (PBXEvent.recordStop):
          final String uuid = packet.field('Unique-ID');
          final String path = packet.field('Record-File-Path');

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

  /**
   * JSON serialization function.
   */
  List toJson() => this.toList(growable: false);
}
