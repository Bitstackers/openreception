part of model;

class Playlist implements Comparable<Playlist>{
  int          id;

  /// The name of the playlist
  String       name;

  /// Path to the directory containing the sound files for this playlist
  String       path;

  /// The sampling rate (in Hertz) of the sound files
  int          rate;

  /// When set to true will randomize the order in which the sound files are played
  bool         shuffle;

  /// Number of channels in the sound files (usually "1" but stereo would be "2")
  int          channels;

  /// Number of milliseconds of silence in between sound files
  int          interval;

  /// List of "break-in" sound files to play
  List<String> chimelist;

  /// Number of seconds in between the start of each "break-in"
  int          chimefreq;

  /// Max number of "break-in" attempts
  int          chimemax;

  Playlist();

  Playlist.fromJson(Map json) {
    id        = json['id'];
    name      = json['name'];
    path      = json['path'];
    rate      = json['rate'];
    shuffle   = json['shuffle'];
    channels  = json['channels'];
    interval  = json['interval'];
    chimelist = json['chimelist'];
    chimefreq = json['chimefreq'];
    chimemax  = json['chimemax'];
  }

  Map toJson() => {
    'id'       : id,
    'name'     : name,
    'path'     : path,
    'rate'     : rate,
    'shuffle'  : shuffle,
    'channels' : channels,
    'interval' : interval,
    'chimelist': chimelist,
    'chimefreq': chimefreq,
    'chimemax' : chimemax
  };

  @override
  int compareTo(Playlist other) => this.name.compareTo(other.name);
}
