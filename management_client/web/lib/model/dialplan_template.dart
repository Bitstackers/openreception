part of model;

class DialplanTemplate {
  int id;
  ExtensionGroup template;

  DialplanTemplate.fromJson(Map json) {
    id = json['id'];

    Map rawTemplate = json['template'];
    template = new ExtensionGroup.fromJson(rawTemplate);
  }
}
