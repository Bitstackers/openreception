part of model;

class UIContexts extends UIModel {
  Map<String, HtmlElement> _contextMap;

  UIContexts() {
    _contextMap = {Context.CalendarEdit: contextCalendarEdit,
                   Context.Home        : contextHome,
                   Context.Homeplus    : contextHomeplus,
                   Context.Messages    : contextMessages};
  }

  @override HtmlElement    get _firstTabElement => null;
  @override HtmlElement    get _focusElement    => null;
  @override HeadingElement get _header          => null;
  @override DivElement     get _help            => null;
  @override HtmlElement    get _lastTabElement  => null;
  @override HtmlElement    get _root            => null;

  /// TODO (TL): get rid of the String selectors. Move to constants.dart or
  /// something similar. Perhaps use/abuse the navigation Context enum?
  HtmlElement get contextCalendarEdit => querySelector('#context-calendar-edit');
  HtmlElement get contextHome         => querySelector('#context-home');
  HtmlElement get contextHomeplus     => querySelector('#context-homeplus');
  HtmlElement get contextMessages     => querySelector('#context-messages');

  void toggleContext(Controller.Place place) {
    _contextMap.forEach((id, element) {
      id == place.context ? element.style.zIndex = '1' : element.style.zIndex = '0';
    });
  }
}
