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
  static const String Unknown                   = 'Unknown';
  static const String WebSites                  = 'Websites';
  static const String OpeningHours              = 'Opening hours';
  static const String Calls                     = 'Calls';
  static const String LocalCalls                = 'Local calls';
  static const String SalesCalls                = 'Salescalls';
  static const String ProductDescription        = 'Product description';
  static final String ContactCalendar           = 'Contact calendar';
  static final String CreateEvent               = 'New event';
  static const String editEvent                 = 'Edit event';
  static final String Create                    = 'Create';
  static final String Update                    = 'Save';
  static final String Delete                    = 'Delete';
  static final String PlaceholderSearch         = 'Searcg...';
  static final String Save                      = 'Save';
  static final String Copy                      = 'Copy';
  static final String Send                      = 'Send';
  static const String Print                     = 'Print';
  static const String Resend                    = 'Resend';
  static final String Cancel                    = 'Cancel';
  static final String Draft                     = 'Draft';
  static final String UnkownWorkHours           = 'Unknown work hours';

  static const String MessageArchive            = 'Message Archive';
  static final String MessageCompose            = 'New Message';
  static final String MessageEdit               = 'Edit Message';
  static const String MessageFilter             = 'Filter Messages';
  static const String MessagePending            = 'Pending';
  static const String MessageResendSelected     = 'Resend Selected';
  static const String MessageSent               = 'Sent';
  static const String MessageTakenAt            = 'Received';
  static const String MessageUpdated            = 'Message updated';
  static const String MessageNotUpdated         = 'Message not updated!';
  static const String MessageEnqueued           = 'Message enqueued';
  static const String MessageNotEnqueued        = 'Message not enqueued!';

  static const String MessageToolTipEnqueued    = 'Message enqueued';
  static const String MessageToolTipSent        = 'Message sent';
  static const String MessageToolTipUnknown     = 'Message status unknown';

  static final String Phone                     = 'Phone';
  static final String No_Information            = '<No Information>';
  static final String CellPhone                 = 'Cellphone';
  static final String LocalExtension            = 'Local Exten.';
  static final String Company                   = 'Company name';
  static final String CallerName                = 'Caller Name';
  static final String PlaceholderSearchResult   = 'No data found';
  static final String PlaceholderMessageCompose = 'Type in message..';
  static final String PleaseCall                = 'Please call';
  static final String WillCallBack              = 'Will call back';
  static final String HasCalled                 = 'Has called';
  static final String Urgent                    = 'Urgent';
  static const String DialOut                   = 'Dial out';
  static const String ContactInformation        = 'Contact Information';
  static const String Caller                    = 'Caller';
  static const String Context                   = 'Context';
  static const String Agent                     = 'Agent';
  static const String Status                    = 'Status';

  static const String ReceptionAlternateNames      = 'Alternate Company Names';
  static const String ReceptionBankingInformation  = 'Banking Information';
  static final String ReceptionContacts            = 'Employees';
  static const String ReceptionEmailaddresses      = 'Email Adresses';
  static const String ReceptionEvents              = 'Company Calendar';
  static const String ReceptionHandling            = 'Handling';
  static const String ReceptionType                = 'Customer type';
  static const String ReceptionPhoneNumbers        = 'Phone numbers';
  static const String ReceptionRegistrationNumbers = 'VAT Numbers';
  static const String ReceptionExtraData           = 'Additional Information';
}