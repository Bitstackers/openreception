/*                     This file is part of Bob
                   Copyright (C) 2014-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of view;

/**
 * Widget for originating a new call.
 */

class CallManagement {
  static const String  className = '${libraryName}.CallManagement';
  static const String NavShortcut = 'T'; 
  bool get muted     => this.context != Context.current;  

  static final String  id        = constant.ID.CALL_MANAGEMENT;
  final        Element element;
  final        Context context;

  bool                get selected     => !nav.Location.isActive(this.element);
  InputElement        get numberField  => this.element.querySelector('#call-originate-number-field');
  ButtonElement       get dialButton   => this.element.querySelector('.call-originate-number-button');
  List<Element>       get nuges        => this.element.querySelectorAll('.nudge');
  List<InputElement>  get inputFields  => this.element.querySelectorAll('input');
  List<ButtonElement> get buttons      => this.element.querySelectorAll('button');
  Element             get header       => this.element.querySelector('legend');

  void set disabled (bool toggle) {
    this.inputFields.forEach((InputElement inputField) {
      inputField.disabled = toggle;
    });

    this.buttons.forEach((ButtonElement button) {
      button.disabled = toggle;
    });
  }
  
  bool get disabled => this.buttons.first.disabled;
  List<Element> get nudges      => this.element.querySelectorAll('.nudge');
  void set NudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  
  /**
   * TODO
   */
  CallManagement(Element this.element, Context this.context) {
    header.children = [Icon.Dialpad,
                       new SpanElement()..text = Label.DialOut,
                       new Nudge('T').element];
    
    
    registerEventListeners();
    
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);
    
    this.element.insertBefore(new Nudge('I').element, this.dialButton);
  }
  
  void _select (_) {
    if (!this.muted) {
      Controller.Context.changeLocation(new nav.Location(context.id, element.id, this.numberField.id));
    }
  }

  _changeActiveCall(model.Call call) {
    //To be defined.
  }

  _dialSelectedNumber(_) {
    if (!this.disabled) {
      Controller.Call.dial(new model.Extension (this.numberField.value), model.Reception.selectedReception, model.Contact.selectedContact);  
    }
  }

  void _originationStarted(String number) {
    this.disabled = true;
  }

  void _originationDone(_) {
    this.disabled = (model.Reception.selectedReception == model.nullReception);
  }

  void registerEventListeners() {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.NudgesHidden = !isPressed);

    event.bus.on(event.dialSelectedContact).listen(this._dialSelectedNumber);
    
    event.bus.on(model.Extension.activeExtensionChanged)
      .listen((model.Extension extension) {
        this.numberField.value = extension.dialString;
    });
    
    event.bus.on(model.Call.currentCallChanged).listen(_changeActiveCall);
    event.bus.on(event.originateCallRequest).listen(_originationStarted);
    event.bus.on(event.originateCallRequestSuccess).listen(_originationDone);
    event.bus.on(event.originateCallRequestFailure).listen(_originationDone);

    this.numberField.onFocus.listen((_) => this.numberField.select());
    
    event.bus.on(event.locationChanged).listen((nav.Location location) => location.setFocusState(element, this.inputFields.first));
    event.bus.on(event.receptionChanged).listen((model.Reception reception) => this.disabled = (reception == model.nullReception));
    
    this.dialButton.onClick.listen((_) => this._dialSelectedNumber(_));
    
    this.element.onClick.listen((_) {
      Controller.Context.changeLocation
          (new nav.Location(this.context.id, this.element.id, this.inputFields.first.id));
    });
  }
}
