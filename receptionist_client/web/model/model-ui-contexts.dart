part of model;

class UIContexts extends UIModel {
  UIContexts();

  HtmlElement get contextCalendarEdit => querySelector('#context-calendar-edit');
  HtmlElement get contextHome         => querySelector('#context-home');
  HtmlElement get contextHomeplus     => querySelector('#context-homeplus');
  HtmlElement get contextMessages     => querySelector('#context-messages');
}
