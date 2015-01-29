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

part of model;

/**
 * A local [ReceptionStub] extension.
 */
class ReceptionStub extends ORModel.ReceptionStub {
  ReceptionStub() : super.none();

  ReceptionStub.fromMap(Map map) : super.fromMap(map);

  ReceptionStub.none() : super.none();
  bool isNotNull() => !this.isNull();
  bool isNull()    => this.ID == Reception.noReception.ID;
}

/**
 * A [Reception].
 */
class Reception extends ORModel.Reception {

  static final Reception noReception = new Reception.none();

  static Reception _selectedReception = noReception;

  static final EventType<Reception> activeReceptionChanged = new EventType<Reception>();

  static Reception get selectedReception                       =>  _selectedReception;
  static           set selectedReception (ORModel.Reception reception) {
    _selectedReception = reception;
    event.bus.fire(event.receptionChanged, _selectedReception);
    event.bus.fire(activeReceptionChanged, _selectedReception);
  }

  Reception.fromMap(Map map) : super.fromMap(map);

  Reception.none() : super.none();

  bool isNotNull() => !this.isNull();
  bool isNull()    => this.ID == Reception.noReception.ID;

  ReceptionStub toStub() =>
    new ReceptionStub()..ID       = this.ID
                       ..fullName = this.fullName;

}
