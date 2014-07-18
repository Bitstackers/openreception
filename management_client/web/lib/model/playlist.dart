part of model;

class Playlist {
  int id;
  String name;
  String path;
  int rate;
  bool shuffle;
  int channels;
  int interval;
  List<String> chimelist;
  int chimefreq;
  int chimemax;

  Playlist();

  factory Playlist.fromJson(Map json) {
    Playlist object = new Playlist();
    object.id = json['id'];
    object.name = json['name'];
    object.path = json['path'];
    object.rate = json['rate'];
    object.shuffle = json['shuffle'];
    object.channels = json['channels'];
    object.interval = json['interval'];
    object.chimelist = json['chimelist'];
    object.chimefreq = json['chimefreq'];
    object.chimemax = json['chimemax'];

    return object;
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
    'chimemax': chimemax};

  static final sortByName = (Playlist a, Playlist b) => a.name.compareTo(b.name);
}
