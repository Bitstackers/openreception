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

part of orf.model;

/// Queue music playlist model class.
///
/// Used for generating an playlist xml configuration file within a
/// FreeSWITCH config.
///
/// Currently unused.
class Playlist {
  int id;
  String name;
  String path;
  bool shuffle;
  int channels;
  int interval;
  List<String> chimelist;
  int chimefreq;
  int chimemax;

  /// Default empty constructor.
  Playlist.empty();

  Playlist.fromDb(int this.id, Map<String, dynamic> json) {
    name = json['name'];
    path = json['path'];
    shuffle = json['shuffle'];
    channels = json['channels'];
    interval = json['interval'];
    chimelist = json['chimelist'] as List<String>;
    chimefreq = json['chimefreq'];
    chimemax = json['chimemax'];
  }
}
