part of model;

class UIReceptionistclientLoading {
  DivElement _myRoot;

  /**
   * Constructor.
   */
  UIReceptionistclientLoading(String id) {
    _myRoot = querySelector('#${id}');
  }

  /**
   * Set visibility according to [value].
   */
  set visible(bool value) {
    _myRoot.style.display = value ? 'flex' : 'none';
  }
}
