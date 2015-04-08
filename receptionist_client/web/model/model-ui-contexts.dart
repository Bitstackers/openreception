part of model;

class UIContexts extends UIModel {
  UIContexts();

  @override HtmlElement get _firstTabElement => null;
  @override HtmlElement get _focusElement    => null;
  @override HtmlElement get _lastTabElement  => null;
  @override HtmlElement get _root            => null;

  /// TODO (TL): get rid of the String selectors. Move to constants.dart or
  /// something similar. Perhaps use/abuse the navigation Context enum?
  HtmlElement get contextCalendarEdit => querySelector('#context-calendar-edit');
  HtmlElement get contextHome         => querySelector('#context-home');
  HtmlElement get contextHomeplus     => querySelector('#context-homeplus');
  HtmlElement get contextMessages     => querySelector('#context-messages');
}
