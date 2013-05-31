/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

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
