/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of components;

class CallQueueItem {
  int         age  = 0;
  String      reception = "...";
  SpanElement ageElement;
  SpanElement callElement;
  model.Call _call = model.nullCall;
  LIElement   element;

  model.Call get call => _call;

  CallQueueItem(model.Call this._call, onCallQueueClick clickHandler) {
    age = new DateTime.now().difference(call.start).inSeconds.ceil();
    String html = '''
      <li class="call-queue-item-default">
        <span class="call-queue-element">${reception} (${call.destination})</span>
        <span class="call-queue-item-seconds">${age}</span>
      </li>
    ''';

    element = new DocumentFragment.html(html).querySelector('.call-queue-item-default');
    ageElement  = element.querySelector('.call-queue-item-seconds');
    callElement = element.querySelector('.call-queue-element');

    storage.Reception.get(call.receptionId).then((r) {
      reception = r.name;
      callElement.text = reception + "(${call.destination})";
    });
    
    element.classes.add('locked');
    
    new Timer.periodic(new Duration(seconds:1), (_) {
      age += 1;
      ageElement.text = age.toString();
    });

    element.onClick.listen((e) => clickHandler(e, this));
  }
}
