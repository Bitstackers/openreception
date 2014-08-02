part of model;

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

  Playlist(int          this.id,
           String       this.name,
           String       this.path,
           bool         this.shuffle,
           int          this.channels,
           int          this.interval,
           List<String> this.chimelist,
           int          this.chimefreq,
           int          this.chimemax);

  Playlist.fromDb(int this.id, Map json) {
    name = json['name'];
    path = json['path'];
    shuffle = json['shuffle'];
    channels = json['channels'];
    interval = json['interval'];
    chimelist = json['chimelist'];
    chimefreq = json['chimefreq'];
    chimemax = json['chimemax'];
  }
}
