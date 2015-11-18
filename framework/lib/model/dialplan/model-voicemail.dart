/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.model.dialplan;

class Voicemail extends Action {
  final String vmBox;
  String note = '';
  String recipient = '';

  Voicemail(String extension) : this.vmBox = 'vm-$extension';

  Voicemail._standard() : this.vmBox = 'vm-\${destination_number}';

  static Voicemail parse (String buffer) {
    throw new UnimplementedError();
  }

  operator == (Voicemail other) => this.vmBox == other.vmBox;

  String toString() => 'Voicemail $vmBox';

  String toJson() => '${Key.voicemail} $vmBox'
      '${recipient.isNotEmpty ? 'sendto:${recipient}' : ''}';

}