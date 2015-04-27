part of model;

/**
 * TODO (TL): Comment
 */
class UIHint {
  /**
   * Constructor.
   */
  UIHint();

  ElementList<DivElement> get _hintElements => querySelectorAll('div.hint');

  /**
   * Toggle the hidden class on all the [_hintElements]
   */
  void toggleHint() {
    _hintElements.forEach((DivElement hint) => hint.classes.toggle('hidden'));
  }
}
