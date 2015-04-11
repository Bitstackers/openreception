part of model;

class UIHelp {
  UIHelp();

  ElementList<DivElement> get _helpElements => querySelectorAll('div.help');

  void toggleHelp() {
    _helpElements.forEach((DivElement help) => help.classes.toggle('hidden'));
  }
}
