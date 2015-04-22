part of model;

class UIContexts {
  Map<String, HtmlElement> _contextMap;

  /**
   * Constructor.
   */
  UIContexts() {
    _contextMap = {Context.CalendarEdit: contextCalendarEdit,
                   Context.Home        : contextHome,
                   Context.Homeplus    : contextHomeplus,
                   Context.Messages    : contextMessages};
  }

  /// TODO (TL): get rid of the String selectors. Move to constants.dart or
  /// something similar. Perhaps use/abuse the navigation Context enum?
  HtmlElement get contextCalendarEdit => querySelector('#context-calendar-edit');
  HtmlElement get contextHome         => querySelector('#context-home');
  HtmlElement get contextHomeplus     => querySelector('#context-homeplus');
  HtmlElement get contextMessages     => querySelector('#context-messages');

  void toggleContext(Controller.Destination destination) {
    _contextMap.forEach((id, element) {
      id == destination.context ? element.style.zIndex = '1' : element.style.zIndex = '0';
    });
  }
}
