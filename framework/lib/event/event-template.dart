part of openreception.event;

abstract class EventTemplate {
  static Map _rootElement(Event event) => {
    Key.event     : event.eventName,
    Key.timestamp : Util.dateTimeToUnixTimestamp (event.timestamp)
  };

  static Map call(CallEvent event) =>
      _rootElement(event)..addAll( {Key.call : event.call});

  static Map peer(PeerState event) =>
      _rootElement(event)..addAll( {Key.peer : event.peer});

  static Map userState(UserState event) =>
      _rootElement(event)..addAll(event.status.asMap);

  static Map calendarEntry(CalendarEvent event) =>
      _rootElement(event)..addAll({Key.calendarEntry: event.calendarEntry});

  static Map channel(ChannelState event) =>
      _rootElement(event)..addAll(
           {Key.channel :
             {Key.ID : event.channelID}});
}