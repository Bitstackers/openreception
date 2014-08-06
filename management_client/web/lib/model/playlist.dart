part of model;

class Playlist implements Comparable<Playlist>{
  int          id;
  String       name;
  String       path;
  int          rate;
  bool         shuffle;
  int          channels;
  int          interval;
  List<String> chimelist;
  int          chimefreq;
  int          chimemax;

  Playlist();

Playlist.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    path = json['path'];
    rate = json['rate'];
    shuffle = json['shuffle'];
    channels = json['channels'];
    interval = json['interval'];
    chimelist = json['chimelist'];
    chimefreq = json['chimefreq'];
    chimemax = json['chimemax'];
  }

  Map toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'rate': rate,
    'shuffle': shuffle,
    'channels': channels,
    'interval': interval,
    'chimelist': chimelist,
    'chimefreq': chimefreq,
    'chimemax': chimemax
  };

  @override
  int compareTo(Playlist other) => this.name.compareTo(other.name);
}
