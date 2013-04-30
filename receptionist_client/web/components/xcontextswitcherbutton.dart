import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/context.dart';

class ContextSwitcherButton extends WebComponent {
  Context       context;
  ImageElement  _alertImg;
  ButtonElement _button;
  ImageElement  _iconActive;
  ImageElement  _iconPassive;

  @observable String get alertMode   => context.alertMode ? '' : 'hidden';
  @observable bool   get disabled    => context.isActive;
  @observable String get classHidden => context.isActive ? '' : 'hidden';

  void inserted() {
    _queryElements();
    _registerEventListeners();
    _resize();
  }

  /**
   * Activate the context associated with the button.
   */
  void _activate() {
    context.activate();
  }

  void _queryElements() {
    _button = this.query('button');
    _iconActive = _button.query('[name="buttonactiveimage"]');
    _iconPassive = _button.query('[name="buttonpassiveimage"]');
    _alertImg = _button.query('[name="buttonalertimage"]');
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
