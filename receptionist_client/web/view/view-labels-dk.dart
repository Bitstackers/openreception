/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library view.labels;

abstract class Label {
  static const String Unknown                   = 'Ukendt';
  static const String WebSites                  = 'Web-sider';
  static const String OpeningHours              = 'Åbningstider';
  static const String Calls                     = 'Opkald';
  static const String LocalCalls                = 'Lokale kald';
  static const String SalesCalls                = 'Sælgere / Analyser';
  static const String ProductDescription        = 'Produktbeskrivelse';
  static final String ContactCalendar           = 'Medarbejderaftaler';
  static final String CreateEvent               = 'Opret aftale';
  static const String editEvent                 = 'Rediger aftale';
  static final String Create                    = 'Opret';
  static final String Update                    = 'Gem';
  static final String Delete                    = 'Slet';
  static final String PlaceholderSearch         = 'Søg...';
  static final String Save                      = 'Gem';
  static final String Copy                      = 'Kopiér';
  static final String Send                      = 'Send';
  static const String Print                     = 'Udskriv';
  static const String Resend                    = 'Gensend';
  static final String Cancel                    = 'Annuller';
  static final String Draft                     = 'Kladde';
  static final String UnkownWorkHours           = 'Ikke oplyst';

  static const String MessageArchive            = 'Beskedarkiv';
  static final String MessageCompose            = 'Opret Besked';
  static final String MessageEdit               = 'Rediger Besked';
  static const String MessageFilter             = 'Filtrér beskeder';
  static const String MessagePending            = 'Afventer';
  static const String MessageResendSelected     = 'Gensend valgte';
  static const String MessageSent               = 'Sendt';
  static const String MessageTakenAt            = 'Modtaget';
  static const String MessageUpdated            = 'Besked opdateret';
  static const String MessageNotUpdated         = 'Besked ikke opdateret!';
  static const String MessageEnqueued           = 'Besked afsendt';
  static const String MessageNotEnqueued        = 'Besked ikke afsendt!';

  static const String MessageToolTipEnqueued    = 'Besked endnu ikke afsendt';
  static const String MessageToolTipSent        = 'Besked afsendt';
  static const String MessageToolTipUnknown     = 'Beskedstatus ukendt';

  static final String Phone                     = 'Telefon';
  static final String No_Information            = '<Ikke oplyst>';
  static final String CellPhone                 = 'Mobilnummer';
  static final String LocalExtension            = 'Lokalnummer';
  static final String Company                   = 'Firmanavn';
  static final String CallerName                = 'Opkalders navn';
  static final String PlaceholderSearchResult   = 'Ingen data fundet';
  static final String PlaceholderMessageCompose = 'Indtast besked..';
  static final String PleaseCall                = 'Ring venligst';
  static final String WillCallBack              = 'Ringer selv tilbage';
  static final String HasCalled                 = 'Har ringet';
  static final String Urgent                    = 'Haster';
  static const String DialOut                   = 'Ring ud';
  static const String ContactInformation        = 'KontaktInformation';
  static const String Caller                    = 'Opkalder';
  static const String Context                   = 'Kontekst';
  static const String Agent                     = 'Agent';
  static const String Status                    = 'Status';
  static const String Active                    = 'Aktive';
  static const String Paused                    = 'Pause';

  static const String ReceptionAlternateNames      = 'Alternative firmanavne';
  static const String ReceptionBankingInformation  = 'Bankoplysninger';
  static final String ReceptionContacts            = 'Medarbejdere';
  static const String ReceptionEmailaddresses      = 'Emailadresser';
  static const String ReceptionEvents              = 'Virksomhedskalender';
  static const String ReceptionHandling            = 'Håndtering';
  static const String ReceptionType                = 'Kundetype';
  static const String ReceptionPhoneNumbers        = 'Hovednumre';
  static const String ReceptionRegistrationNumbers = 'CVR Numre';
  static const String ReceptionExtraData           = 'Ekstra information';
  static const String ReceptionSearch              = 'Søg efter en virksomhed';

}