part of model;

class DialplanTemplate {
  int id;
  ExtensionGroup _template;

  //Easy way to make a deep copy clone.
  ExtensionGroup get template => new ExtensionGroup.fromJson(JSON.decode(JSON.encode(_template)));

  DialplanTemplate.fromJson(Map json) {
    id = json['id'];

    Map rawTemplate = json['template'];
    _template = new ExtensionGroup.fromJson(rawTemplate);
  }
}
