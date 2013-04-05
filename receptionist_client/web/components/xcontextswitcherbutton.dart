import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/section.dart';

@observable
class ContextSwitcherButton extends WebComponent {
  ButtonElement button;
  bool disabled;
  String icon;
  String iconActive;
  String iconPassive;
  ImageElement img;
  Section section;

  void inserted() {
    section.stream.listen(_toggle);

    button = this.query('button');
    img = button.query('img');

    disabled = section.isActive;

    /*
     * TODO fix these paths so they are centralized somewhere sensible.
     */
    iconActive = '../icons/${section.id}_active.svg';
    iconPassive = '../icons/${section.id}.svg';

    icon = section.isActive ? iconActive : iconPassive;

    button.onMouseOver.listen((_) => icon = iconActive);
    button.onMouseOut.listen((_) => icon = iconPassive);

    _resize();
    window.onResize.listen((_) => _resize());
  }

  void _resize() {
    /*
     * TODO do we _require_ square buttons? Setting img width to button width
     * will only give us square buttons if the img src was square in the first
     * place. For square buttons we can do this
     *
     *    button.style.height = '${button.client.width}px';
     *
     * else just leave it was it is now.
     */
    img.style.width = '${button.client.width}px';
  }

  void _toggle(String sectionId) {
    if (sectionId == section.id) {
      icon = iconActive;
      disabled = true;
    } else {
      icon = iconPassive;
      disabled = false;
    }
  }

  void activate() {
    section.activate();
  }
}
