part of model;

/**
 * TODO (TL): Comment
 */
class UIReceptionistclientReady {
  DivElement _myRoot;

  /**
   * Constructor.
   */
  UIReceptionistclientReady(String id) {
    _myRoot = querySelector('#${id}');
  }

  /**
   * Set visibility according to [value].
   */
  set visible(bool value) {
    _myRoot.style.display = value ? 'flex' : 'none';
  }
}

