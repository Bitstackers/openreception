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
  DivElement body;
  Context _context;
  Element element;


  SearchComponent<String> agentSearch;
  SearchComponent<String> typeSearch;
  SearchComponent<model.ReceptionStub> receptionSearch;
  SearchComponent<model.Contact> contactSearch;

  Element       get header                       => this.element.querySelector('legend');
  ButtonElement get saveMessageButton            => this.element.querySelector('button.save');
  ButtonElement get resendMessageButton          => this.element.querySelector('button.resend');

  MessageFilter(Element this.element, Context this._context) {
    assert(element != null);

    body = querySelector('.${CssClass.messageSearchBox}');

    this._setupLabels();

    agentSearch = new SearchComponent<String>(body.querySelector('#${Id.messageSearchAgent}'), _context, 'message-search-agent-searchbar')
      ..searchPlaceholder = 'Agent...'
      ..updateSourceList([Label.All, '1', '2', '10'])
      ..selectElement(Label.All)
      ..selectedElementChanged = (String text) {
        if (text != Label.All) {
          model.MessageFilter.current.userID = int.parse(text);
        } else {
          model.MessageFilter.current.userID = null;
        }
        searchParametersChanged();
    };

    typeSearch = new SearchComponent<String>(body.querySelector('#${Id.messageSearchType}'), _context, 'message-search-type-searchbar')
      ..searchPlaceholder = 'Type...'
      ..updateSourceList([Label.All, Label.Sent, Label.Saved, Label.Pending])
      ..selectElement(Label.All)
      ..selectedElementChanged = (String text) {
      switch (text) {
        case Label.Sent:
          model.MessageFilter.current.messageState = ORModel.MessageState.Sent;
          break;

        case Label.Saved:
          model.MessageFilter.current.messageState = ORModel.MessageState.Saved;
          break;

        case Label.Pending:
          model.MessageFilter.current.messageState = ORModel.MessageState.Pending;
          break;

        default:
          model.MessageFilter.current.messageState = null;
          break;

      }

      searchParametersChanged();
    };

    receptionSearch = new SearchComponent<model.ReceptionStub>(body.querySelector('#${Id.messageSearchReception}'), _context, 'message-search-company-searchbar')
      ..searchPlaceholder = Label.ReceptionSearch
      ..selectedElementChanged = (model.ReceptionStub receptionStub) {
      if (receptionStub.isNull()) {
        model.MessageFilter.current.receptionID = null;
        model.MessageFilter.current.contactID = null;
        contactSearch.updateSourceList([model.Contact.noContact]);
        searchParametersChanged();
        return;
      }
        storage.Reception.get(receptionStub.ID).then((model.Reception reception) {

          model.MessageFilter.current.receptionID = reception.ID;
          model.MessageFilter.current.contactID = null;
          searchParametersChanged();

          model.Contact.list(reception.ID).then((List<model.Contact> contacts) {
            contactSearch.updateSourceList([model.Contact.noContact..fullName = Label.All]..addAll(contacts));
          }).catchError((error) {
            contactSearch.updateSourceList(new model.ContactList.emptyList().toList(growable: false));
          });
        });
      }
      ..searchFilter = (model.ReceptionStub reception, String searchText) {
        return reception.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..listElementToString = companyListElementToString;

      storage.Reception.list().then((List<model.ReceptionStub> receptions) {
        receptionSearch.updateSourceList(receptions.toList());
      });

    contactSearch = new SearchComponent<model.Contact>(body.querySelector('#${Id.messageSearchContact}'), _context, 'message-search-contact-searchbar')
      ..searchPlaceholder = Label.ReceptionContacts
      ..listElementToString = contactListElementToString
      ..searchFilter = (model.Contact contact, String searchText) {
        return contact.fullName.toLowerCase().contains(searchText.toLowerCase());
      }
      ..selectedElementChanged = (model.Contact contact) {
        if (contact == model.Contact.noContact) {
          model.MessageFilter.current.contactID = null;
        } else {
          model.MessageFilter.current.contactID = contact.ID;
        }

        searchParametersChanged();
      };
  }

  void _setupLabels() {
    this.header.children = [Icon.Filter,
                            new SpanElement()..text = Label.MessageFilter];
  }

  String companyListElementToString(model.ReceptionStub reception, String searchText) {
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

  String contactListElementToString(model.Contact contact, String searchText) {
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
    log.debug('messagesearch. The search parameters have changed.');
    event.bus.fire(event.messageFilterChanged, model.MessageFilter.current);
  }
}
