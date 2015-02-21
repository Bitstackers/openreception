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

  static const String ContactCalendar           = 'Medarbejderaftaler';
  static const String ContactWorkHours          = 'Arbejdstider';
  static const String ContactJobTitle           = 'Titel';
  static const String ContactHandling           = 'Håndtering';
  static const String ContactResponsibilities   = 'Ansvarsområder';
  static const String ContactDepartment         = 'Afdeling';
  static const String ContactPhone              = 'Telefonnumre';
  static const String ContactRelations          = 'Relationer';
  static const String ContactEmails             = 'Email Adresser';
  static const String ContactExtraInfo          = 'Ekstra Information';
  static const String ContactBackups            = 'Backup Kontakter';

  static const String CreateEvent               = 'Opret aftale';
  static const String editEvent                 = 'Rediger aftale';
  static const String Create                    = 'Opret';
  static const String Update                    = 'Gem';
  static const String Delete                    = 'Slet';
  static const String PlaceholderSearch         = 'Søg...';
  static const String Save                      = 'Gem';
  static const String Copy                      = 'Kopiér';
  static const String Send                      = 'Send';
  static const String Print                     = 'Udskriv';
  static const String Resend                    = 'Gensend';
  static const String Cancel                    = 'Annuller';
  static const String Draft                     = 'Kladde';
  static const String UnkownWorkHours           = 'Ikke oplyst';
  static const String All                       = 'Alle';
  static const String Sent                      = 'Sendt';
  static const String Saved                     = 'Gemt';
  static const String Pending                   = 'Venter';

  static const String MessageArchive            = 'Beskedarkiv';
  static const String MessageCompose            = 'Opret Besked';
  static const String MessageEdit               = 'Rediger Besked';
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

  static const String Phone                     = 'Telefon';
  static const String No_Information            = '<Ikke oplyst>';
  static const String CellPhone                 = 'Mobilnummer';
  static const String LocalExtension            = 'Lokalnummer';
  static const String Company                   = 'Firmanavn';
  static const String CallerName                = 'Opkalders navn';
  static const String PlaceholderSearchResult   = 'Ingen data fundet';
  static const String PlaceholderMessageCompose = 'Indtast besked..';
  static const String PleaseCall                = 'Ring venligst';
  static const String WillCallBack              = 'Ringer selv tilbage';
  static const String HasCalled                 = 'Har ringet';
  static const String Urgent                    = 'Haster';
  static const String Dial                      = 'Ring op';
  static const String PhoneNumber               = 'Nummer';
  static const String ContactInformation        = 'KontaktInformation';
  static const String Caller                    = 'Opkalder';
  static const String Context                   = 'Kontekst';
  static const String Agent                     = 'Agent';
  static const String Status                    = 'Status';
  static const String Active                    = 'Aktive';
  static const String Paused                    = 'Pause';

  static const String ReceptionAddresses           = 'Adresser';
  static const String ReceptionAlternateNames      = 'Alternative firmanavne';
  static const String ReceptionBankingInformation  = 'Bankoplysninger';
  static const String ReceptionContacts            = 'Medarbejdere';
  static const String ReceptionEmailaddresses      = 'Emailadresser';
  static const String ReceptionEvents              = 'Virksomhedskalender';
  static const String ReceptionHandling            = 'Håndtering';
  static const String ReceptionType                = 'Kundetype';
  static const String ReceptionPhoneNumbers        = 'Hovednumre';
  static const String ReceptionRegistrationNumbers = 'CVR Numre';
  static const String ReceptionExtraData           = 'Ekstra information';
  static const String ReceptionSearch              = 'Søg efter en virksomhed';
  static const String ReceptionWelcomeMsgPlacehold = '...';

}