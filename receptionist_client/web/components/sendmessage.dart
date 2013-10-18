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

import 'dart:html';

import 'package:polymer/polymer.dart';

import '../classes/common.dart';
import '../classes/environment.dart' as environment;
import '../classes/logger.dart';
import '../classes/model.dart' as model;

@CustomTag('send-message')
class SendMessage extends PolymerElement with ApplyAuthorStyle {
  @observable bool   callsBack               = true;
  final String       cancelButtonLabel       = 'Annuller';
  @observable String cellphone               = '';
  @observable String company                 = '';
  @observable bool   emergency               = false;
  @observable bool   hasCalled               = false;
  @observable String localno                 = '';
  @observable String name                    = '';
  @observable String phone                   = '';
  final String       placeholderCellphone    = 'Mobil';
  final String       placeholderCompany      = 'Firmanavn';
  final String       placeholderLocalno      = 'Lokalnummer';
  final String       placeholderName         = 'Navn';
  final String       placeholderPhone        = 'Telefon';
  final String       placeholderSearch       = 'Søg...';
  final String       placeholderSearchResult = 'Ingen data fundet';
  final String       placeholderText         = 'Besked';
  @observable bool   pleaseCall              = false;
  final String       recipientTitle          = 'Modtagere';
  final String       saveButtonLabel         = 'Gem';
  @observable String search                  = '';
  @observable String searchResult            = '';
  final String       sendButtonLabel         = 'Send';
  @observable String text                    = '';
  final String       title                   = 'Besked';

  void select(Event e, var detail, Node target) {
    int id = int.parse((target as LIElement).id.split('_').last);
    //environment.contact = environment.organization.contactList.getContact(id);

    log.debug('ContactInfo.select updated environment.contact to ${environment.contact}');
  }
}
