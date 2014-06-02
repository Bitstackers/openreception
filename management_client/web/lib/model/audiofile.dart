part of model;

class Audiofile {
  String filepath;
  String shortname;

  Audiofile();

  factory Audiofile.fromJson(Map json) {
    Audiofile object = new Audiofile();
    object.filepath = json['filepath'];
    object.shortname = json['shortname'];

    return object;
  }

  String toJson() {
    Map data = {
      'filepath': filepath,
      'shortname': shortname
    };

    return JSON.encode(data);
  }
}
