import 'dart:html';

//import '../classes/common.dart';
import '../classes/context.dart';

class ContextSwitcherButton {
   String        activeImagePath  = '';
              ImageElement  _alertImg;
   String        alertMode        = 'hidden';
              ButtonElement _button;
   String        classHidden      = '';
    Context       context;
   bool          disabled         = false;
              ImageElement  _iconActive;
              ImageElement  _iconPassive;
              bool          _isCreated       = false;
   String        passiveImagePath = '';

  ContextSwitcherButton() {}

  void enteredView() {
    if(!_isCreated) {
      _queryElements();
      _registerEventListeners();

      // Context is first available in inserted(). DON'T MOVE TO CREATED()!
//      context.alertUpdated.listen((Context value) {
//        alertMode = value.alertMode ? '' : 'hidden';
//      });
//
//      context.activeUpdated.listen((Context value) {
//        disabled = value.isActive;
//        classHidden = disabled ? '' : 'hidden';
//      });

      disabled = context.isActive;
      classHidden = disabled ? '' : 'hidden';

      activeImagePath = 'images/${context.id}_active.svg';
      passiveImagePath = 'images/${context.id}.svg';

      _isCreated = true;
    }

    _resize();
  }

  /**
   * Activate the context associated with the button.
   */
//  void _activate() {
//    if(!context.isActive) {
//      context.activate();
//    }
//  }

  void _queryElements() {
//    _button = getShadowRoot('context-switcher-button').querySelector('button');
//    _iconActive = _button.querySelector('[name="button_active_image"]');
//    _iconPassive = _button.querySelector('[name="button_passive_image"]');
//    _alertImg = _button.querySelector('[name="button_alert_image"]');
  }

  void _registerEventListeners() {
    /*
     * We take advantage of the fact that disabled buttons ignore mouse-over/out
     * events, so it's perfectly fine to just toggle the hidden class on the
     * iconActive element, as we can never remove nor add the hidden class on
     * the currently active button, because it has also been disabled.
     */

    _button.onMouseOver.listen((_) => _iconActive.classes.remove('hidden'));
    _button.onMouseOut.listen((_) => _iconActive.classes.add('hidden'));

    window.onResize.listen((_) => _resize());
  }

  /**
   * Resize the button and all the contained images.
   */
  void _resize() {
    num buttonWidth = _button.client.width;

    num alertSize = buttonWidth / 2;
    num buttonMargin = buttonWidth / 3;

    _button.style.height = '${buttonWidth}px';

    _button.style.marginTop = '${buttonMargin}px';
    _button.style.marginBottom = '${buttonMargin}px';

    _iconActive.style.height = '${buttonWidth}px';
    _iconActive.style.width = '${buttonWidth}px';

    _iconPassive.style.height = '${buttonWidth}px';
    _iconPassive.style.width = '${buttonWidth}px';

    _alertImg.style.height = '${alertSize}px';
    _alertImg.style.width = '${alertSize}px';
  }
}
