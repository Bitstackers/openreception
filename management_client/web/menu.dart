library menu;

import 'dart:html';

/**
 * Widget to control the menu on the left side of the screen.
 * It lets the user switch between windows.
 */
class Menu {
  //root DOM element for the menu.
  HtmlElement element;

  Map<String, ButtonElement> menus;

  Menu(HtmlElement this.element) {
    //Build up collections of menus for easier use later.
    menus = {
      'organization':
          element.querySelector('#organization-button') as ButtonElement,
      'reception': element.querySelector('#reception-button') as ButtonElement,
      'contact': element.querySelector('#contact-button') as ButtonElement,
      'dialplan': element.querySelector('#dialplan-button') as ButtonElement,
      'soundfile': element.querySelector('#soundfile-button') as ButtonElement,
      'user': element.querySelector('#user-button') as ButtonElement,
      'ivr': element.querySelector('#ivr-button') as ButtonElement,
      'message': element.querySelector('#message-button') as ButtonElement,
      'cdr': element.querySelector('#cdr-button') as ButtonElement,
      'music': element.querySelector('#music-button') as ButtonElement,
    };
  }

  //Highlights the right button.
  void _highlightItem(String window) {
    menus.forEach((String name, ButtonElement button) {
      button.classes.toggle('faded', window != name);
    });
  }
}
