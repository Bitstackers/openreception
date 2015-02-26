part of controller;

abstract class Extension {
  static void change (Model.Extension newExtension) {
    Model.Extension.selectedExtension = newExtension;
  }
}
