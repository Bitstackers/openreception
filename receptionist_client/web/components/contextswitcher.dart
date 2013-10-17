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

import 'package:polymer/polymer.dart';

import '../classes/context.dart';
import '../classes/environment.dart' as environment;
import '../classes/events.dart' as event;

@CustomTag('context-switcher')
class ContextSwitcher extends PolymerElement {
  @observable environment.ContextList contextList;

  bool get applyAuthorStyles => true; //Applies external css styling to component.

  void created() {
    super.created();

    event.bus.on(event.contextListUpdated).listen((environment.ContextList list) {
      contextList = list;
    });
  }
}

@CustomTag('context-switcher-button')
class ContextSwitcherButton extends PolymerElement {
  @observable String        activeImagePath  = '';
              ImageElement  _alertImg;
  @observable String        alertMode        = 'hidden';
              ButtonElement _button;
  @observable String        classHidden      = '';
  @published  Context       context;
  @observable bool          enabled          = false;
              ImageElement  _iconActive;
              ImageElement  _iconPassive;
              bool          _isCreated       = false;
  @observable String        passiveImagePath = '';

  bool get applyAuthorStyles => true; //Applies external css styling to component.

  void inserted() {
    if(!_isCreated) {
      enabled = context.isActive;
      classHidden = enabled ? '' : 'hidden';

      activeImagePath = 'images/${context.id}_active.svg';
      passiveImagePath = 'images/${context.id}.svg';

      _queryElements();
      _registerEventListeners();

      _isCreated = true;
    }

    _resize();
  }

  /**
   * Activate the context associated with the button.
   */
  void _activate() {
    if(!context.isActive) {
      context.activate();
    }
  }

  void _queryElements() {
    _button = getShadowRoot('context-switcher-button').query('button');
    _iconActive = _button.query('[name="button_active_image"]');
    _iconPassive = _button.query('[name="button_passive_image"]');
    _alertImg = _button.query('[name="button_alert_image"]');
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

    context.alertUpdated.listen((Context value) {
      alertMode = value.alertMode ? '' : 'hidden';
    });

    context.activeUpdated.listen((Context value) {
      enabled = value.isActive;
      classHidden = enabled ? '' : 'hidden';
    });
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
