part of model;

class Audiofile {
  String filepath;
  String shortname;

  Audiofile();

  factory Audiofile.fromJson(Map json) {
    Audiofile object = new Audiofile()
      ..filepath = json['filepath']
      ..shortname = json['shortname'];

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
