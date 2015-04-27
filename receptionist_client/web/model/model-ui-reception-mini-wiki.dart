part of model;

class UIReceptionMiniWiki extends UIModel {
  final Keyboard             _keyboard = new Keyboard();
  final DivElement           _myRoot;
  final NodeValidatorBuilder _validator = new NodeValidatorBuilder()
                                                ..allowHtml5()
                                                ..allowTextElements()
                                                ..allowElement('a', attributes: ['href']);

  /**
   * Constructor.
   */
  UIReceptionMiniWiki(DivElement this._myRoot) {
    _help.text = 'alt+m';

    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _body;
  @override HtmlElement get _focusElement    => _body;
  @override SpanElement get _header          => _root.querySelector('h4 > span');
  @override SpanElement get _headerExtra     => _root.querySelector('h4 > span + span');
  @override DivElement  get _help            => _root.querySelector('div.help');
  @override HtmlElement get _lastTabElement  => _body;
  @override HtmlElement get _root            => _myRoot;

  DivElement get _body => _root.querySelector('.generic-widget-body');

  /**
   * Remove all data from the body and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _body.text = '';
  }

  /**
   * Add [miniWiki] markdown to the widget.
   */
  set miniWiki(String miniWiki) {
    _body.setInnerHtml(Markdown.markdownToHtml(miniWiki), validator: _validator);
  }

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen((_) => _body.focus());
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    final Map<String, EventListener> bindings =
        {'Shift+Tab': _handleShiftTab,
         'Tab'      : _handleTab};

    _hotKeys.registerKeysPreventDefault(_keyboard, bindings);
  }
}
