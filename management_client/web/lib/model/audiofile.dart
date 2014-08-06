part of model;

class Audiofile {
  String filepath;
  String shortname;

  Audiofile.fromJson(Map json) {
    filepath  = json['filepath'];
    shortname = json['shortname'];
  }

  Map toJson() => {
    'filepath' : filepath,
    'shortname': shortname
  };
}
