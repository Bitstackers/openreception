part of model;

class UIHelp {
  /**
   * Constructor.
   */
  UIHelp();

  ElementList<DivElement> get _helpElements => querySelectorAll('div.help');

  /**
   * Toggle the hidden class on all the [_helpElements]
   */
  void toggleHelp() {
    _helpElements.forEach((DivElement help) => help.classes.toggle('hidden'));
  }
}
