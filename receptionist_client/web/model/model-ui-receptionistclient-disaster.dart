part of model;

/**
 * TODO (TL): Comment
 */
class UIReceptionistclientDisaster {
  DivElement _myRoot;

  /**
   * Constructor.
   */
  UIReceptionistclientDisaster(String id) {
    _myRoot = querySelector('#${id}');
  }

  /**
   * Set visibility according to [value].
   */
  set visible(bool value) {
    _myRoot.style.display = value ? 'flex' : 'none';
  }
}
