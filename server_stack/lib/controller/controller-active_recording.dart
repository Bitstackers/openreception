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

/// Controller library for listing and querying recordings currently active.
library ors.controller.active_recording;

import 'dart:async';

import 'package:orf/exceptions.dart';
import 'package:ors/model.dart' as model;
import 'package:ors/response_utils.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

/// Controller for the [model.ActiveRecordings] container class.
class ActiveRecording {
  final model.ActiveRecordings _activeRecordings;

  /// Create a new [ActiveRecording] controller that wraps around
  /// an [model.ActiveRecordings] container and transforms its content
  /// to [shelf.Response]s.
  ActiveRecording(this._activeRecordings);

  /// Retrieve and JSON encode the current [ActiveRecordings] model class.
  Future<shelf.Response> list(shelf.Request request) async =>
      okJson(_activeRecordings);

  /// Retrieve and JSON encode a single recording from the
  /// [ActiveRecordings] model class.
  Future<shelf.Response> get(shelf.Request request) async {
    final String channelId = shelf_route
        .getPathParameters(request)
        .containsKey('cid') ? shelf_route.getPathParameter(request, 'cid') : '';

    if (channelId.isEmpty) {
      return clientError('No channel id supplied');
    }

    try {
      final recording = _activeRecordings.get(channelId);

      return okJson(recording);
    } on NotFound {
      return notFound('No active recording on channel $channelId');
    }
  }
}
