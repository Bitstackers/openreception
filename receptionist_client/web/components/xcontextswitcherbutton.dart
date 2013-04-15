import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/context.dart';

@observable
class ContextSwitcherButton extends WebComponent {
  Context context;

  ImageElement _alertImg;
  ButtonElement _button;
  ImageElement _iconActive;
  ImageElement _iconPassive;

  String get alertMode => context.alertMode ? '' : 'hidden';
  bool get disabled => context.isActive;
  String get hidden => context.isActive ? '' : 'hidden';

  void inserted() {
    _button = this.query('button');
    _iconActive = _button.query('[name="buttonactiveimage"]');
    _iconPassive = _button.query('[name="buttonpassiveimage"]');
    _alertImg = _button.query('[name="buttonalertimage"]');

    /*
     * We take advantage of the fact that disabled buttons ignore mouse-over/out
     * events, so it's perfectly fine to just toggle the hidden class on the
     * iconActive element, as we can never remove nor add the hidden class on
     * the currently active button, because it has also been disabled.
     */
    _button.onMouseOver.listen((_) => _iconActive.classes.remove('hidden'));
    _button.onMouseOut.listen((_) => _iconActive.classes.add('hidden'));

    _resize();
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

  /**
   * Activate the context associated with the button.
   */
  void activate() {
    context.activate();
  }
}
