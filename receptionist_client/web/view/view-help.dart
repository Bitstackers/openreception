part of view;

class Help {
  /// TODO (TL): This could do with some sizing magic, so we're ensured that
  /// each little help box is always fairly well positioned, no matter the size
  /// of the content.
  Help() {
    registerEventListeners();
  }

  /// TODO (TL): Allow each widget to register the contents of its help box.
  /// This is language dependant, so having it in the HTML is a temporary
  /// thing. Widget that have some sort of help text, should consume this object
  /// and register its actual help text.

  void registerEventListeners() {
    _hotKeys.onF1.listen((_) => querySelectorAll('.help').classes.toggle('hidden'));
  }
}
