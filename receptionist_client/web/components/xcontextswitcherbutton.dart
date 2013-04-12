import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/context.dart';

@observable
class ContextSwitcherButton extends WebComponent {
  Context context;

  ImageElement _alertImg;
  ButtonElement _button;
  ImageElement _iconActive;

  String get alertMode => context.alertMode ? '' : 'hidden';
  bool get disabled => context.isActive;
  String get hidden => context.isActive ? '' : 'hidden';

  void inserted() {
    _button = this.query('button');
    _iconActive = _button.query('[name="buttonactiveimage"]');
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

  void _resize() {
    num newSize = _button.client.width / 2;
    num margin = newSize / 1.5;

    _button.style.height = '${_button.client.width}px';
    _button.style.marginTop = '${margin}px';
    _button.style.marginBottom = '${margin}px';

    _alertImg.style.height = '${newSize}px';
    _alertImg.style.width = '${newSize}px';
  }

  void activate() {
    context.activate();
  }
}
