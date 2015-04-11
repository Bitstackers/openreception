part of controller;

final Map<String, Place> _Places =
  {'${Context.Home}-${Widget.ContactCalendar}'         : new Place(Context.Home, Widget.ContactCalendar),
   '${Context.Home}-${Widget.ContactData}'             : new Place(Context.Home, Widget.ContactData),
   '${Context.Home}-${Widget.ContactSelector}'         : new Place(Context.Home, Widget.ContactSelector),
   '${Context.Home}-${Widget.MessageCompose}'          : new Place(Context.Home, Widget.MessageCompose),
   '${Context.Home}-${Widget.ReceptionCalendar}'       : new Place(Context.Home, Widget.ReceptionCalendar),
   '${Context.Home}-${Widget.ReceptionCommands}'       : new Place(Context.Home, Widget.ReceptionCommands),
   '${Context.Homeplus}-${Widget.ReceptionAltNames}'   : new Place(Context.Homeplus, Widget.ReceptionAltNames),
   '${Context.CalendarEdit}-${Widget.CalendarEditor}'  : new Place(Context.CalendarEdit, Widget.CalendarEditor),
   '${Context.Messages}-${Widget.MessageArchiveFilter}': new Place(Context.Messages, Widget.MessageArchiveFilter)};

/**
 * A [Place] points to a location in the application. It does this by utilizing
 * the [Context] and [Widget] enum's.
 *
 * The optional [from] Place MAY be used to inform a widget from whence it was
 * brought into focus.
 */
class Place {
  Context context = null;
  Place   from    = null;
  Widget  widget  = null;

  Place(Context this.context, Widget this.widget, {Place this.from});

  operator == (Place other) => (context == other.context) && (widget == other.widget);

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

  final Bus<Place> _bus = new Bus<Place>();

  /// TODO (TL): Feels ugly having this map here. Maybe allow widgets to
  /// register themselves? Seems more explicit that way. Hmmm..
  final Map<Context, Widget> _defaultWidget =
    {Context.CalendarEdit: Widget.CalendarEditor,
     Context.Home        : Widget.ReceptionCalendar,
     Context.Homeplus    : Widget.ReceptionAltNames,
     Context.Messages    : Widget.MessageArchiveFilter};
  final Map<Context, Widget> _widgetHistory = {};

  /**
   * Push [place] to the [onGo] stream. If [pushState] is true, then also add
   * [place] to the browser history.
   */
  void go(Place place, {bool pushState: true}) {
    if(place.widget == null) {
      if(_widgetHistory.containsKey(place.context)) {
        place.widget = _widgetHistory[place.context];
      } else {
        place.widget = _defaultWidget[place.context];
      }
    }

    _widgetHistory[place.context] = place.widget;

    if(pushState) {
      window.history.pushState(null, '${place}', '#${place}');
    }

    _bus.fire(place);
  }

  /**
   * Turn the current window.location into a [Place] and call [go] using that.
   * If [pushState] is true, then also add the resulting [Place] to the browser
   * history.
   */
  void goWindowLocation({bool pushState: true}) {
    String hash = '';

    if(window.location.hash.isNotEmpty) {
      hash = window.location.hash.substring(1);
    }

    if(hash.isEmpty || !_Places.containsKey(hash)) {
      goHome();
    } else {
      go(_Places[hash], pushState: pushState);
    }
  }

  /**
   * Convenience method to navigate to [Context.CalendarEdit].
   */
  void goCalendarEdit(Place from) {go(new Place(Context.CalendarEdit, null, from: from));}

  /**
   * Convenience method to navigate to [Context.Home].
   */
  void goHome() {go(new Place(Context.Home, null));}

  /**
     * Convenience method to navigate to [Context.Homeplus].
     */
  void goHomeplus() {go(new Place(Context.Homeplus, null));}

  /**
   * Convenience method to navigate to [Context.Messages].
   */
  void goMessages() {go(new Place(Context.Messages, null));}

  /**
   * Fires a [Place] whenever navigation is happening.
   */
  Stream<Place> get onGo => _bus.stream;

  void _registerEventListeners() {
    window.onPopState.listen((_) => goWindowLocation(pushState: false));
  }
}
