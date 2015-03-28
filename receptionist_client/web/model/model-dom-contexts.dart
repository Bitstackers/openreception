part of model;

class DomContexts extends DomModel {
  DomContexts();

  HtmlElement get contextCalendarEdit => querySelector('#context-calendar-edit');
  HtmlElement get contextHome         => querySelector('#context-home');
  HtmlElement get contextHomeplus     => querySelector('#context-homeplus');
  HtmlElement get contextMessages     => querySelector('#context-messages');
}
