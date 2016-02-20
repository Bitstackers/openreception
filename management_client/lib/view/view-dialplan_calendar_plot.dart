part of management_tool.view;

class DialplanCalenderPlot {
  final DivElement element = new DivElement()..hidden = true;
  final DivElement _legendBox = new DivElement()
    ..style.marginLeft = '1em'
    ..style.float = 'left';

  final TableElement _calendarTable = new TableElement()
    ..style.float = 'left'
    ..classes.add('calendar');

  DialplanCalenderPlot() {
    _calendarTable.createTHead().children = [
      new TableRowElement()
        ..children = [
          new TableCellElement()
            ..text = '00:00'
            ..style.maxWidth = '10px',
          new TableCellElement()..text = 'Man',
          new TableCellElement()..text = 'Tirs',
          new TableCellElement()..text = 'Ons',
          new TableCellElement()..text = 'Tors',
          new TableCellElement()..text = 'Fre',
          new TableCellElement()..text = 'Lør',
          new TableCellElement()..text = 'Søn',
        ]
    ];

    TableSectionElement body = _calendarTable.createTBody();

    for (int i = 0; i < 24; i++) {
      String id = i < 10 ? '0$i' : '$i';

      TableRowElement wholeHour = new TableRowElement()
        ..children = [
          new TableCellElement()
            ..id = 'hour_${id}_00'
            ..text = '$id:30',
          new TableCellElement()..id = 'mon_${id}_00',
          new TableCellElement()..id = 'tue_${id}_00',
          new TableCellElement()..id = 'wed_${id}_00',
          new TableCellElement()..id = 'thu_${id}_00',
          new TableCellElement()..id = 'fri_${id}_00',
          new TableCellElement()..id = 'sat_${id}_00',
          new TableCellElement()..id = 'sun_${id}_00',
        ];

      String hpId = i < 9 ? '0${i+1}' : '${i+1}';

      TableRowElement halfPastHour = new TableRowElement()
        ..children = [
          new TableCellElement()
            ..id = 'hour_${id}_30'
            ..text = '${hpId}:00',
          new TableCellElement()..id = 'mon_${id}_30',
          new TableCellElement()..id = 'tue_${id}_30',
          new TableCellElement()..id = 'wed_${id}_30',
          new TableCellElement()..id = 'thu_${id}_30',
          new TableCellElement()..id = 'fri_${id}_30',
          new TableCellElement()..id = 'sat_${id}_30',
          new TableCellElement()..id = 'sun_${id}_30',
        ];

      body.children.add(wholeHour);
      body.children.add(halfPastHour);

      element.children = [
        _calendarTable,
        _legendBox..children = [new HeadingElement.h4()..text = 'Åbningstider']
      ];
    }
  }

  void dim() {
    element.classes.toggle('dimmed', true);
  }

  void set dialplan(model.ReceptionDialplan rdp) {
    _clearOpeningHours();

    List availableColours = ['red', 'brown', 'blue', 'green'];

    _legendBox.children = [new HeadingElement.h3()..text = 'Åben-handlinger'];
    rdp.open.forEach((model.HourAction ha) {
      _renderHourAction(ha, availableColours.removeLast());
    });
    _legendBox.children.addAll([
      new HeadingElement.h3()..text = 'Lukket-handlinger',
      new DivElement()
        ..classes.addAll(['calendar-legend'])
        ..children = [
          new OListElement()
            ..children = ([]..addAll(rdp.defaultActions.map(_actionToLi)))
        ]
    ]);

    element.hidden = false;
  }

  _toTdId(model.WeekDay wday, int hour, int minute) {
    switch (wday) {
      case model.WeekDay.mon:
        return 'mon_${hour < 10 ? '0$hour' : hour}_${minute < 10 ? '0$minute': minute}';
      case model.WeekDay.tue:
        return 'tue_${hour < 10 ? '0$hour' : hour}_${minute < 10 ? '0$minute': minute}';
      case model.WeekDay.wed:
        return 'wed_${hour < 10 ? '0$hour' : hour}_${minute < 10 ? '0$minute': minute}';
      case model.WeekDay.thur:
        return 'thu_${hour < 10 ? '0$hour' : hour}_${minute < 10 ? '0$minute': minute}';
      case model.WeekDay.fri:
        return 'fri_${hour < 10 ? '0$hour' : hour}_${minute < 10 ? '0$minute': minute}';
      case model.WeekDay.sat:
        return 'sat_${hour < 10 ? '0$hour' : hour}_${minute < 10 ? '0$minute': minute}';
      case model.WeekDay.sun:
        return 'sun_${hour < 10 ? '0$hour' : hour}_${minute < 10 ? '0$minute': minute}';
      case model.WeekDay.all:
        throw new ArgumentError();
    }
  }

  _clearOpeningHours() {
    querySelectorAll('td.marked-red').classes.toggle('marked-red', false);
    querySelectorAll('td.marked-brown').classes.toggle('marked-brown', false);
    querySelectorAll('td.marked-green').classes.toggle('marked-green', false);
    querySelectorAll('td.marked-blue').classes.toggle('marked-blue', false);
  }

  _renderOpeningHour(model.OpeningHour oh, String colour) {
    //TODO handle "all" days.
    Iterable openDays;
    if (oh.fromDay.index <= oh.toDay.index) {
      openDays =
          model.WeekDay.values.sublist(oh.fromDay.index, oh.toDay.index + 1);
    } else {
      openDays =
          model.WeekDay.values.sublist(oh.toDay.index, oh.fromDay.index + 1);
    }

    for (model.WeekDay wday in openDays) {
      for (int hour = oh.fromHour; hour < oh.toHour; hour++) {
        if (hour == oh.fromHour && oh.fromMinute > 0) {
          querySelector('#${_toTdId(wday, hour, 30)}')
              .classes
              .toggle('marked-$colour', true);
        } else if (hour == oh.toHour - 1 && oh.toMinute > 0) {
          querySelector('#${_toTdId(wday, hour, 00)}')
              .classes
              .toggle('marked-$colour', true);
          querySelector('#${_toTdId(wday, hour, 30)}')
              .classes
              .toggle('marked-$colour', true);
          querySelector('#${_toTdId(wday, hour+1, 00)}')
              .classes
              .toggle('marked-$colour', true);
        } else {
          querySelector('#${_toTdId(wday, hour, 00)}')
              .classes
              .toggle('marked-$colour', true);
          querySelector('#${_toTdId(wday, hour, 30)}')
              .classes
              .toggle('marked-$colour', true);
        }
      }
    }

    element.classes.toggle('dimmed', false);
  }

  void _renderHourAction(model.HourAction ha, String colour) {
    ha.hours.forEach((model.OpeningHour oh) => _renderOpeningHour(oh, colour));

    _legendBox.children.add(new DivElement()
      ..classes.addAll(['calendar-legend', colour])
      ..children = [
        new OListElement()..children = ([]..addAll(ha.actions.map(_actionToLi)))
      ]);
  }

  LIElement _actionToLi(model.Action action) {
    final LIElement li = new LIElement()..text = '??';
    if (action is model.Playback) {
      li.children = [
        new SpanElement()..text = 'Afspil lydfil ',
        new SpanElement()
          ..text = action.filename
          ..style.fontWeight = 'bold'
      ];
    } else if (action is model.Transfer) {
      li.text = 'Direkte omstilling til ${action.extension}';
    } else if (action is model.Notify) {
      li.text = 'Annoncér kald';
    } else if (action is model.Ringtone) {
      li.text = 'Send ${action.count} ringtoner';
    } else if (action is model.Enqueue) {
      li.text = 'Sæt kald i kø';
    } else if (action is model.Ivr) {
      li.text = 'Send kald til IVR-menu ${action.menuName}';
    } else if (action is model.Voicemail) {
      li.text = 'Send kald til voicemail box ${action.vmBox}';
    } else if (action is model.ReceptionTransfer) {
      li.text = 'Omstil til reception ${action.extension}';
    }

    return li;
  }
}
