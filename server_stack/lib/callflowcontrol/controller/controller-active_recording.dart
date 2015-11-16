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

part of openreception.call_flow_control_server.controller;

/**
 * Controller for the [ActiveRecording] model class.
 */
class ActiveRecording {

  final Logger log = new Logger('${libraryName}.ActiveRecording');

  /**
   * Retrieve and JSON encode the current [ActiveRecordings] model class.
   */
  Future<shelf.Response> list (shelf.Request request) async =>
      _okJson(Model.ActiveRecordings.instance);

  /**
   * Retrieve and JSON encode a single recording from the [ActiveRecordings]
   * model class.
   */
  Future<shelf.Response> get (shelf.Request request) async {
    String channelId = '';
    try {
      String channelId = shelf_route.getPathParameters(request).containsKey('cid') ?
          shelf_route.getPathParameter(request, 'cid')
          : '';

      if (channelId.isEmpty) {
        return _clientError('No channel id supplied');
      }

      return _okJson(Model.ActiveRecordings.instance.get(channelId));
    }
    on ORStorage.NotFound {
      return _notFound('No active recording on channel $channelId');
    }
  }
}