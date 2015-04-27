part of controller;

final Map<String, Destination> _destinations =
  {'${Context.Home}-${Widget.ContactCalendar}'              : new Destination(Context.Home, Widget.ContactCalendar),
   '${Context.Home}-${Widget.ContactData}'                  : new Destination(Context.Home, Widget.ContactData),
   '${Context.Home}-${Widget.ContactSelector}'              : new Destination(Context.Home, Widget.ContactSelector),
   '${Context.Home}-${Widget.GlobalCallQueue}'              : new Destination(Context.Home, Widget.GlobalCallQueue),
   '${Context.Home}-${Widget.MessageCompose}'               : new Destination(Context.Home, Widget.MessageCompose),
   '${Context.Homeplus}-${Widget.ReceptionAddresses}'       : new Destination(Context.Homeplus, Widget.ReceptionAddresses),
   '${Context.Homeplus}-${Widget.ReceptionAltNames}'        : new Destination(Context.Homeplus, Widget.ReceptionAltNames),
   '${Context.Homeplus}-${Widget.ReceptionBankInfo}'        : new Destination(Context.Homeplus, Widget.ReceptionBankInfo),
   '${Context.Home}-${Widget.ReceptionCalendar}'            : new Destination(Context.Home, Widget.ReceptionCalendar),
   '${Context.Home}-${Widget.ReceptionCommands}'            : new Destination(Context.Home, Widget.ReceptionCommands),
   '${Context.Homeplus}-${Widget.ReceptionEmail}'           : new Destination(Context.Homeplus, Widget.ReceptionEmail),
   '${Context.Homeplus}-${Widget.ReceptionMiniWiki}'        : new Destination(Context.Homeplus, Widget.ReceptionMiniWiki),
   '${Context.Home}-${Widget.ReceptionOpeningHours}'        : new Destination(Context.Home, Widget.ReceptionOpeningHours),
   '${Context.Home}-${Widget.ReceptionProduct}'             : new Destination(Context.Home, Widget.ReceptionProduct),
   '${Context.Home}-${Widget.ReceptionSalesmen}'            : new Destination(Context.Home, Widget.ReceptionSalesmen),
   '${Context.Home}-${Widget.ReceptionSelector}'            : new Destination(Context.Home, Widget.ReceptionSelector),
   '${Context.Homeplus}-${Widget.ReceptionTelephoneNumbers}': new Destination(Context.Homeplus, Widget.ReceptionTelephoneNumbers),
   '${Context.Homeplus}-${Widget.ReceptionType}'            : new Destination(Context.Homeplus, Widget.ReceptionType),
   '${Context.Homeplus}-${Widget.ReceptionVATNumbers}'      : new Destination(Context.Homeplus, Widget.ReceptionVATNumbers),
   '${Context.Homeplus}-${Widget.ReceptionWebsites}'        : new Destination(Context.Homeplus, Widget.ReceptionWebsites),
   '${Context.CalendarEdit}-${Widget.CalendarEditor}'       : new Destination(Context.CalendarEdit, Widget.CalendarEditor),
   '${Context.Messages}-${Widget.MessageArchiveFilter}'     : new Destination(Context.Messages, Widget.MessageArchiveFilter)};

/**
 * A [Destination] points to a location in the application. It does this by
 * utilizing the [context] and [widget] enum's.
 *
 * The optional [from] [Destination] MAY be used to inform a widget from where
 * it was brought into focus.
 *
 * The optional [cmd] [Cmd] can be used as a lightweight payload given
 * to the destination.
 */
class Destination {
  Context     context = null;
  Cmd         cmd     = null;
  Destination from    = null;
  Widget      widget  = null;

  Destination(Context this.context, Widget this.widget, {Destination this.from, Cmd this.cmd});

  operator == (Destination other) => (context == other.context) && (widget == other.widget);

  String toString() => '${context}-${widget}';
}

/**
 * Handles navigation for the application. This is a singleton.
 */
class Navigate {
  static final Navigate _singleton = new Navigate._internal();
  factory Navigate() => _singleton;

  Navigate._internal() {
    _registerEventListeners();
  }

  final Bus<Destination> _bus = new Bus<Destination>();

  /// TODO (TL): Feels ugly having this map here. Maybe allow widgets to
  /// register themselves? Seems more explicit that way. Hmmm..
  final Map<Context, Widget> _defaultWidget =
    {Context.CalendarEdit: Widget.CalendarEditor,
     Context.Home        : Widget.ReceptionSelector,
     Context.Homeplus    : Widget.ReceptionMiniWiki,
     Context.Messages    : Widget.MessageArchiveFilter};
  final Map<Context, Widget> _widgetHistory = {};

  /**
   * Push [destination] to the [onGo] stream. If [pushState] is true, then also
   * add [destination] to the browser history.
   */
  void go(Destination destination, {bool pushState: true}) {
    if(destination.widget == null) {
      if(_widgetHistory.containsKey(destination.context)) {
        destination.widget = _widgetHistory[destination.context];
      } else {
        destination.widget = _defaultWidget[destination.context];
      }
    }

    _widgetHistory[destination.context] = destination.widget;

    if(pushState) {
      window.history.pushState(null, '${destination}', '#${destination}');
    }

    _bus.fire(destination);
  }

  /**
   * Turn the current window.location into a [Destination] and call [go] using
   * that.
   * If [pushState] is true, then also add the resulting [Destination] to the
   * browser history.
   */
  void goWindowLocation({bool pushState: true}) {
    String hash = '';

    if(window.location.hash.isNotEmpty) {
      hash = window.location.hash.substring(1);
    }

    if(hash.isEmpty || !_destinations.containsKey(hash)) {
      goHome();
    } else {
      go(_destinations[hash], pushState: pushState);
    }
  }

  /**
   * Convenience method to navigate to [Context.CalendarEdit].
   */
  void goCalendarEdit({Destination from}) {go(new Destination(Context.CalendarEdit, null, from: from, cmd: from.cmd));}

  /**
   * Convenience method to navigate to [Context.Home].
   */
  void goHome() {go(new Destination(Context.Home, null));}

  /**
     * Convenience method to navigate to [Context.Homeplus].
     */
  void goHomeplus() {go(new Destination(Context.Homeplus, null));}

  /**
   * Convenience method to navigate to [Context.Messages].
   */
  void goMessages() {go(new Destination(Context.Messages, null));}

  /**
   * Fires a [Destination] whenever navigation is happening.
   */
  Stream<Destination> get onGo => _bus.stream;

  void _registerEventListeners() {
    window.onPopState.listen((_) => goWindowLocation(pushState: false));
  }
}
