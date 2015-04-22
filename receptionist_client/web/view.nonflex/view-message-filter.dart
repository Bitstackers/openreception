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

part of view;

class MessageFilter{
  static final Logger log = new Logger('${libraryName}.MessageFilter');

  DivElement body;
  Context _context;
  Element element;


  Component.SearchComponent<String> agentSearch;
  Component.SearchComponent<String> typeSearch;
  Component.SearchComponent<Model.ReceptionStub> receptionSearch;
  Component.SearchComponent<Model.Contact> contactSearch;

  Element       get header                       => this.element.querySelector('legend');
  ButtonElement get saveMessageButton            => this.element.querySelector('button.save');
  ButtonElement get resendMessageButton          => this.element.querySelector('button.resend');

  MessageFilter(Element this.element, Context this._context) {
    assert(element != null);

    body = querySelector('.${CssClass.messageSearchBox}');

    this._setupLabels();

    agentSearch = new Component.SearchComponent<String>
      (body.querySelector('#${Id.messageSearchAgent}'),
                          _context,
                          'message-search-agent-searchbar')
      ..searchPlaceholder = 'Agent...'
      ..updateSourceList([Label.All, '1', '2', '10'])
      ..selectElement(Label.All)
      ..selectedElementChanged = (String text) {
        if (text != Label.All) {
          Model.MessageFilter.current.userID = int.parse(text);
        } else {
          Model.MessageFilter.current.userID = null;
        }
        searchParametersChanged();
    };

    typeSearch = new Component.SearchComponent<String>(body.querySelector('#${Id.messageSearchType}'), _context, 'message-search-type-searchbar')
      ..searchPlaceholder = 'Type...'
      ..updateSourceList([Label.All, Label.Sent, Label.Saved, Label.Pending])
      ..selectElement(Label.All)
      ..selectedElementChanged = (String text) {
      switch (text) {
        case Label.Sent:
          Model.MessageFilter.current.messageState = ORModel.MessageState.Sent;
          break;

        case Label.Saved:
          Model.MessageFilter.current.messageState = ORModel.MessageState.Saved;
          break;

        case Label.Pending:
          Model.MessageFilter.current.messageState = ORModel.MessageState.Pending;
          break;

        default:
          Model.MessageFilter.current.messageState = null;
          break;

      }

      searchParametersChanged();
    };

    receptionSearch = new Component.SearchComponent<Model.ReceptionStub>(body.querySelector('#${Id.messageSearchReception}'), _context, 'message-search-company-searchbar')
      ..searchPlaceholder = Label.ReceptionSearch
      ..selectedElementChanged = (Model.ReceptionStub receptionStub) {
      if (receptionStub.isNull()) {
        Model.MessageFilter.current.receptionID = null;
        Model.MessageFilter.current.contactID = null;
        contactSearch.updateSourceList([Model.Contact.noContact]);
        searchParametersChanged();
        return;
      }
        storage.Reception.get(receptionStub.ID).then((Model.Reception reception) {

          Model.MessageFilter.current.receptionID = reception.ID;
          Model.MessageFilter.current.contactID = null;
          searchParametersChanged();

          Model.Contact.list(reception.ID).then((List<Model.Contact> contacts) {
            contactSearch.updateSourceList([Model.Contact.noContact..fullName = Label.All]..addAll(contacts));
          }).catchError((error) {
            contactSearch.updateSourceList(new Model.ContactList.emptyList().toList(growable: false));
          });
        });
      }
      ..searchFilter = (Model.ReceptionStub reception, String searchText) {
        return reception.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..listElementToString = companyListElementToString;

      storage.Reception.list().then((List<Model.ReceptionStub> receptions) {
        receptionSearch.updateSourceList(receptions.toList());
      });

    contactSearch = new Component.SearchComponent<Model.Contact>(body.querySelector('#${Id.messageSearchContact}'), _context, 'message-search-contact-searchbar')
      ..searchPlaceholder = Label.ReceptionContacts
      ..listElementToString = contactListElementToString
      ..searchFilter = (Model.Contact contact, String searchText) {
        return contact.fullName.toLowerCase().contains(searchText.toLowerCase());
      }
      ..selectedElementChanged = (Model.Contact contact) {
        if (contact == Model.Contact.noContact) {
          Model.MessageFilter.current.contactID = null;
        } else {
          Model.MessageFilter.current.contactID = contact.ID;
        }

        searchParametersChanged();
      };
  }

  void _setupLabels() {
    this.header.children = [Icon.Filter,
                            new SpanElement()..text = Label.MessageFilter];
  }

  String companyListElementToString(Model.ReceptionStub reception, String searchText) {
    if(searchText == null || searchText.isEmpty) {
      return reception.name;
    } else {
      String text = reception.name;
      int matchIndex = text.toLowerCase().indexOf(searchText.toLowerCase());
      String before  = text.substring(0, matchIndex);
      String match   = text.substring(matchIndex, matchIndex + searchText.length);
      String after   = text.substring(matchIndex + searchText.length, text.length);
      return '${before}<em>${match}</em>${after}';
    }
  }

  String contactListElementToString(Model.Contact contact, String searchText) {
    if(searchText == null || searchText.isEmpty) {
      return contact.fullName;
    } else {
      String text = contact.fullName;
      int matchIndex = text.toLowerCase().indexOf(searchText.toLowerCase());
      String before  = text.substring(0, matchIndex);
      String match   = text.substring(matchIndex, matchIndex + searchText.length);
      String after   = text.substring(matchIndex + searchText.length, text.length);
      return '${before}<em>${match}</em>${after}';
    }
  }

  void searchParametersChanged() {
    log.finest('messagesearch. The search parameters have changed.');
    event.bus.fire(event.messageFilterChanged, Model.MessageFilter.current);
  }
}
