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

part of model;

/**
 * A local [ReceptionStub] extension.
 */
class ReceptionStub extends ORModel.ReceptionStub {
  ReceptionStub() : super.none();

  ReceptionStub.fromMap(Map map) : super.fromMap(map);

  ReceptionStub.none() : super.none();
  bool get isNotEmpty => !this.isEmpty;
  bool get isEmpty    => this.ID == Reception.noReception.ID;
}

/**
 * A [Reception].
 */
class Reception extends ORModel.Reception {

  static final Reception noReception = new Reception.none();

  static Reception _selectedReception = noReception;

  static Bus<Reception> _receptionChange = new Bus<Reception>();
  static Stream<Reception> get onReceptionChange => _receptionChange.stream;

  static Reception get selectedReception                       =>  _selectedReception;
  static           set selectedReception (ORModel.Reception reception) {
    _selectedReception = reception;
    _receptionChange.fire(_selectedReception);
  }

  Reception.fromMap(Map map) : super.fromMap(map);

  Reception.none() : super.none();

  bool get isNotEmpty => !this.isEmpty;
  bool get isEmpty    => this.ID == Reception.noReception.ID;

  ReceptionStub toStub() =>
    new ReceptionStub()..ID       = this.ID
                       ..fullName = this.fullName;

  //FIXME: Please, I am sooo broken.
  String get miniWikiMarkdown => "##FIXME";
}