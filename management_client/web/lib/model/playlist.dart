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
    Playlist object = new Playlist()
      ..id = json['id']
      ..name = json['name']
      ..path = json['path']
      ..rate = json['rate']
      ..shuffle = json['shuffle']
      ..channels = json['channels']
      ..interval = json['interval']
      ..chimelist = json['chimelist']
      ..chimefreq = json['chimefreq']
      ..chimemax = json['chimemax'];

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
