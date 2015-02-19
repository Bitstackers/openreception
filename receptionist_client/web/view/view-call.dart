/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of view;


abstract class CallCssClass {
  static const String destroyed = 'destroyed';
  static const String enqueued  = 'enqueued';
}

/**
 * Widget representing a call.
 */
class Call {

  static const String className = '${libraryName}.Call';

  Duration age = new Duration(seconds: 0);

  SpanElement ageElement;
  SpanElement callElement;
  model.Call _call = model.nullCall;
  LIElement element;
  ButtonElement get pickupButton   => this.element.querySelector('.pickup-button');
  ButtonElement get parkButton     => this.element.querySelector('.park-button');
  ButtonElement get hangupButton   => this.element.querySelector('.hangup-button');
  ButtonElement get transferButton => this.element.querySelector('.transfer-button');

  model.Call get call => _call;
  List<Element> get nuges => this.element.querySelectorAll('.nudge');

  Call(model.Call this._call) {
    DocumentFragment htmlChunk = new DocumentFragment.html(
     '''
      <li class="call-queue-item-default call">
        <span class="call-queue-element"></span>
        <span class="call-queue-item-seconds"></span>
        <button class="pickup-button">Svar</button>
        <button class="hangup-button">L&aelig;g p&aring;</button>
        <button class="park-button">Parker</button>
        <button class="transfer-button">Viderestil</button>
      </li>
    ''');

    age = new DateTime.now().difference(call.start);
    element = htmlChunk.querySelector('.call-queue-item-default');

    // Button click handlers
    this.pickupButton.onClick  .listen((_) => call.pickup());
    this.parkButton.onClick    .listen((_) => call.park());
    this.hangupButton.onClick  .listen((_) => call.hangup());
    this.transferButton.onClick.listen((_) => call.transfer (model.Call.currentCall));

    ageElement = element.querySelector('.call-queue-item-seconds')
        ..text = _renderDuration(age);

    callElement = element.querySelector('.call-queue-element')
        ..text = '${Label.ReceptionWelcomeMsgPlacehold} (${call.destination}) ${call.state}';

    storage.Reception.get(call.receptionId).then((model.Reception reception) {
      callElement.text = reception.name + "(${call.destination}) - ${call.state}";
    });

    Duration pollInterval = new Duration(seconds: 1);

    Timer timer;
    timer = new Timer.periodic(pollInterval, (_) {
      if (this.destroyed) {
        timer.cancel();
        return;
      }

      this.age += pollInterval;
      ageElement.text = _renderDuration(age);
    });

    this._renderButtons();
  }

  /**
   * Determine if this element marked for destruction.
   */
  bool get destroyed => this.element.classes.contains('destroyed');


  /**
   * Quick implementation of the desired visual representation of a duration (m:ss).
   */
  static String _renderDuration (Duration duration) {
    if (duration.inSeconds > 59) {
      int minutes = duration.inSeconds ~/ 60;
      int seconds = duration.inSeconds - (minutes * 60);

      // Hotfix of missing leading zero.
      if (seconds < 10) {
        return '${minutes}:0${seconds}';
      }
        else {
          return '${minutes}:${seconds}';
        }
    } else {
      return '0:${duration.inSeconds}';
    }
  }

  void set disabled (bool isDisabled) {
    List widgetButtons = [this.pickupButton, this.parkButton,
                          this.transferButton, this.hangupButton];

    widgetButtons.forEach((ButtonElement button) => button.disabled = isDisabled);
  }

  void render() {
    this._renderButtons();
  }

  void _renderButtons () {
    this.pickupButton.hidden   = ! (call.availableForUser(model.User.currentUser) &&
                                    call.state != model.CallState.SPEAKING);
    this.parkButton.hidden     = ! (call.availableForUser(model.User.currentUser) &&
                                    call.state == model.CallState.SPEAKING);
    this.hangupButton.hidden   = ! (call.assignedAgent == model.User.currentUser);
    this.transferButton.hidden = ! (call.assignedAgent == model.User.currentUser);
  }

  /**
   * Event handler for taking care of the queueJoin events in the Widget.
   *
   * Simply hides the call from sight, as it should be removed only by a
   * callHangup event.
   */
  void _callQueueJoinHandler (model.Call queuedCall) {
    const String context = '${className}._callQueueJoinHandler';

    if (this.call == queuedCall) {
      log.debugContext("Unhiding call ${queuedCall.ID} from call queue.", context);
      this.element.hidden = false;
    }
  }

  /**
   * Event handler for taking care of the queueLeave events in the Widget.
   */
  void _callQueueRemoveHandler (_) {
    const String context = '${className}._callQueueRemoveHandler';
    log.debugContext("Hiding call ${this.call.ID} from call queue.", context);
    this.element.classes.toggle('speaking', true);

    this.element.hidden = true;

    this._renderButtons();
  }

  /**
   * Event handler for taking care of the park events in the Widget.
   */
  void _callParkHandler (_) {
    const String context = '${className}._callParkHandler';
    log.debugContext("Unhiding call ${this.call.ID} from call list.", context);
    this.element.classes.toggle('speaking', false);
    this.element.classes.toggle('parked', true);

      this.element.hidden = false;
      this._renderButtons();
  }

  /**
   * Event handler for taking care of the callHangup event in the Widget.
   */
  void _callHangupHandler (_) {
    const String context = '${className}._callHangupHandler';
      log.debugContext("Removing call ${this.call.ID} from call queue view.", context);

      this.element.classes.toggle('destroyed', true);
      this.disabled = true;

      // Delay removal to show that the call is hung up before.
      new Timer(new Duration(seconds: 3), this.element.remove);
  }

  /**
   * Event handler for taking care of the callHangup event in the Widget.
   */
  void _callTransferHandler (_) {
    const String context = '${className}._callTransferHandler ';
    log.debugContext("Hiding call ${this.call.ID} from call queue.", context);

    this.element.classes.toggle("transferred", true);


    this.element.hidden = true;
    this._renderButtons();
  }
}
