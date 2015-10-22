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

class ActiveRecordings extends IterableBase {

  static final instance = new ActiveRecordings();

  Logger _log = new Logger ('$libraryName.ActiveRecordings');

  Map _recordings = {};

  Iterator<Map> get iterator => _recordings.keys.map
      ((String key) => {key : _recordings[key]}).iterator;

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