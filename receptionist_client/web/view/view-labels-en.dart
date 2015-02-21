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

  static const String ContactCalendar           = 'Contact calendar';
  static const String ContactWorkHours          = 'Work hours';
  static const String ContactJobTitle           = 'Job Title';
  static const String ContactHandling           = 'Handling';
  static const String ContactResponsibilities   = 'Resposibilities';
  static const String ContactDepartment         = 'Department';
  static const String ContactPhone              = 'Phones';
  static const String ContactRelations          = 'Relations';
  static const String ContactEmails             = 'Emails';
  static const String ContactExtraInfo          = 'Extra Information';
  static const String ContactBackups            = 'Backup Contacts';

  static const String CreateEvent               = 'New event';
  static const String editEvent                 = 'Edit event';
  static const String Create                    = 'Create';
  static const String Update                    = 'Save';
  static const String Delete                    = 'Delete';
  static const String PlaceholderSearch         = 'Search...';
  static const String Save                      = 'Save';
  static const String Copy                      = 'Copy';
  static const String Send                      = 'Send';
  static const String Print                     = 'Print';
  static const String Resend                    = 'Resend';
  static const String Cancel                    = 'Cancel';
  static const String Draft                     = 'Draft';
  static const String UnkownWorkHours           = 'Unknown work hours';
  static const String All                       = 'All';
  static const String Sent                      = 'Sent';
  static const String Saved                     = 'Saved';
  static const String Pending                   = 'Pending';

  static const String MessageArchive            = 'Message Archive';
  static const String MessageCompose            = 'New Message';
  static const String MessageEdit               = 'Edit Message';
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

  static const String Phone                     = 'Phone';
  static const String No_Information            = '<No Information>';
  static const String CellPhone                 = 'Cellphone';
  static const String LocalExtension            = 'Local Exten.';
  static const String Company                   = 'Company name';
  static const String CallerName                = 'Caller Name';
  static const String PlaceholderSearchResult   = 'No data found';
  static const String PlaceholderMessageCompose = 'Type in message..';
  static const String PleaseCall                = 'Please call';
  static const String WillCallBack              = 'Will call back';
  static const String HasCalled                 = 'Has called';
  static const String Urgent                    = 'Urgent';
  static const String Dial                      = 'Dial';
  static const String PhoneNumber               = 'Phone number';
  static const String ContactInformation        = 'Contact Information';
  static const String Caller                    = 'Caller';
  static const String Context                   = 'Context';
  static const String Agent                     = 'Agent';
  static const String Status                    = 'Status';
  static const String Active                    = 'Active';
  static const String Paused                    = 'Paused';

  static const String ReceptionAddresses           = 'Addresses';
  static const String ReceptionAlternateNames      = 'Alternate Company Names';
  static const String ReceptionBankingInformation  = 'Banking Information';
  static const String ReceptionContacts            = 'Employees';
  static const String ReceptionEmailaddresses      = 'Email Adresses';
  static const String ReceptionEvents              = 'Company Calendar';
  static const String ReceptionHandling            = 'Handling';
  static const String ReceptionType                = 'Customer type';
  static const String ReceptionPhoneNumbers        = 'Phone numbers';
  static const String ReceptionRegistrationNumbers = 'VAT Numbers';
  static const String ReceptionExtraData           = 'Additional Information';
  static const String ReceptionSearch              = 'Search Reception';
  static const String ReceptionWelcomeMsgPlacehold = '...';
}