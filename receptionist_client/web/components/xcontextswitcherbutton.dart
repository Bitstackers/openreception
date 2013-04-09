import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/context.dart';

@observable
class ContextSwitcherButton extends WebComponent {
  Context context;
  String alertIcon = '../icons/contextalert.svg'; // ???? path here? yuk!

  DivElement _alertDiv;
  ImageElement _alertImg;
  ButtonElement _button;
  ImageElement _img;
  String _iconActive;
  String _iconPassive;

  String get alertMode => context.alertMode ? '' : 'hidden';
  bool get disabled => context.isActive;
  String get icon => context.isActive ? _iconActive : _iconPassive;

  void inserted() {
    _button = this.query('button');
    _img = _button.query('img');
    _alertDiv = _button.query('div');
    _alertImg = _alertDiv.query('img');

    _iconActive = '../icons/${context.id}_active.svg'; // ???? path here? yuk!
    _iconPassive = '../icons/${context.id}.svg';       // ???? path here? yuk!

    /*
     * We take advantage of the fact that disabled buttons ignore mouse-over/out
     * events, so it's perfectly fine to just blindly set the src attribute
     * of the button image element, as the currently active button (which is then
     * disabled) does not emit any events.
     */
    _button.onMouseOver.listen((_) => _img.src = _iconActive);
    _button.onMouseOut.listen((_) =>  _img.src = _iconPassive);

    _resize();
    window.onResize.listen((_) => _resize());
  }

  void _resize() {
    num newSize = _button.client.width / 2;
    num margin = newSize / 1.5;

    _button.style.marginTop = '${margin}px';
    _button.style.marginBottom = '${margin}px';

    _alertDiv.style.width = '${newSize}px';
    _alertDiv.style.height = '${newSize}px';
    _alertImg.style.height = '${newSize}px';
    _alertImg.style.width = '${newSize}px';
  }

  void activate() {
    context.activate();
  }
}
