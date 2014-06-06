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

  static final String  id        = constant.ID.CALL_MANAGEMENT;
  static const String  className = '${libraryName}.CallManagement';
  final        Element element;
  final        Context context;

  bool                get muted        => !nav.Location.isActive(this.element);
  InputElement        get numberField  => this.element.querySelector('#call-originate-number-field');
  List<Element>       get nuges        => this.element.querySelectorAll('.nudge');
  List<InputElement>  get inputFields  => this.element.querySelectorAll('input');
  List<ButtonElement> get buttonFields => this.element.querySelectorAll('button');

  void set disabled (bool toggle) {
    this.inputFields.forEach((InputElement inputField) {
      inputField.disabled = toggle;
    });

    this.buttonFields.forEach((ButtonElement button) {
      button.disabled = toggle;
    });
  }
  
  bool get disabled => this.buttonFields.first.disabled;
  
  /**
   * TODO
   */
  CallManagement(Element this.element, Context this.context) {
    registerEventListeners();
    
    this.element.insertBefore(new Nudge('T').element, this.inputFields.first);
    
    this.hideNudges(true);
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

  void _originationSucceded(dynamic) {
    this.disabled = (model.Reception.selectedReception == model.nullReception);
  }

  void _originationFailed(dynamic) {
    this.disabled = (model.Reception.selectedReception == model.nullReception);
  }

  void hideNudges(bool hidden) {
    nuges.forEach((Element element) {
      element.hidden = hidden;
    });
  }

  void registerEventListeners() {
    event.bus.on(event.dialSelectedContact).listen(this._dialSelectedNumber);
    
    event.bus.on(model.Extension.activeExtensionChanged)
      .listen((model.Extension extension) {
        this.numberField.value = extension.dialString;
    });
    
    event.bus.on(model.Call.currentCallChanged).listen(_changeActiveCall);
    event.bus.on(event.originateCallRequest).listen(_originationStarted);
    event.bus.on(event.originateCallRequestSuccess).listen(_originationSucceded);
    event.bus.on(event.originateCallRequestFailure).listen(_originationFailed);
    event.bus.on(event.keyMeta).listen((bool isPressed) {
      this.hideNudges(!isPressed);
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) => location.setFocusState(element, this.inputFields.first));
    event.bus.on(event.receptionChanged).listen((model.Reception reception) => this.disabled = (reception == model.nullReception));

    element.onClick.listen((_) {
      Controller.Context.changeLocation
          (new nav.Location(this.context.id, this.element.id, this.inputFields.first.id));
    });
  }
}
