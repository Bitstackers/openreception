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

part of components;

class CompanySelector {
  final String                 organizationSearchPlaceholder = 'Søg efter en virksomhed';
        model.Organization     organization      = model.nullOrganization;
        model.OrganizationList organizationList  = new model.OrganizationList();
        DivElement             element;

        InputElement searchBox;
        UListElement resultsList;
        SpanElement companyselectortext;
        DivElement companydropdown;
        bool withDropDown = false;
        List<LIElement> ulOrganizationList = new List<LIElement>();

        int selectedItemIndex = -1;
        int highlightedIndex = -1;

  CompanySelector(DivElement this.element) {
    element.classes.addAll(['chosen-container','chosen-container-single']);

    String html = '''
      <a class="chosen-single" tabindex="-1">
        <span id="companyselectortext">${organizationSearchPlaceholder}</span>
        <div><b></b></div>
      </a>
      <div class="chosen-drop">
        <div class="chosen-search">
          <input type="text" autocomplete="off"></input>
        </div>
        <ul class="chosen-results"></ul>
      <div>
    ''';

    DocumentFragment frag = new DocumentFragment.html(html);
    companyselectortext = frag.querySelector('#companyselectortext');
    companydropdown = frag.querySelector('.chosen-drop');
    searchBox = companydropdown.querySelector('.chosen-search > input');
    resultsList = companydropdown.querySelector('.chosen-results');
    element.children.addAll(frag.children);

    registerEventHandlers();
    initialFill();
  }

  void activeDropDown() {
    if(!withDropDown) {
      element.classes.add('chosen-with-drop');
      withDropDown = true;
    }
  }

  void activeElement() {
    element.classes.toggle('chosen-container-active', true);
  }

  void clearSelection() {
    companyselectortext.text = organizationSearchPlaceholder;
  }

  void deactiveDropDown() {
    if(withDropDown) {
      element.classes.remove('chosen-with-drop');
      withDropDown = false;
    }
  }

  void deactiveElement() {
    element.classes.toggle('chosen-container-active', false);
  }

  void highlightElement() {
    int elementIndex = 0;
    bool found = false;
    for(LIElement item in resultsList.children) {
      if(elementIndex == highlightedIndex) {
        if(item.offsetTop < resultsList.scrollTop) {
          resultsList.scrollTop = item.offsetTop;

        } else if(resultsList.scrollTop + resultsList.clientHeight - item.clientHeight <= item.offsetTop) {
          resultsList.scrollTop = item.offsetTop + item.clientHeight - resultsList.clientHeight;
        }
        found = true;
      }
      item.classes.toggle('highlighted', elementIndex == highlightedIndex);
      elementIndex += 1;
    }

    if(found == false) {
      resultsList.children.first.classes.toggle('highlighted', true);
      resultsList.scrollTop = 0;
      highlightedIndex = int.parse(resultsList.children.first.attributes['index']);
    }
  }

  void initialFill() {
    storage.getOrganizationList()
      .then((model.OrganizationList list) => organizationList = list)
      .catchError((error) => log.critical('CompanySelector._initialFill storage.getOrganizationList failed with ${error}'))
      .whenComplete(() {
        updateSourceList();
        preformSearch(searchBox.value);
      });
  }

  void nextElement() {
    if(!withDropDown) {
      activeDropDown();
    } else if(highlightedIndex < resultsList.children.length -1) {
      highlightedIndex += 1;
      highlightElement();
    }
  }

  void preformSearch(String searchText) {
    resultsList.children.clear();
    for(var liOrganization in ulOrganizationList) {
      model.BasicOrganization organization = organizationList.elementAt(int.parse(liOrganization.attributes['index']));
      if(searchText.isEmpty) {
        resultsList.children.add(liOrganization
            ..innerHtml = organization.name);

      } else if(liOrganization.text.toLowerCase().contains(searchText.toLowerCase())) {
        List<Match> matches = organization.name.toLowerCase().allMatches(searchText.toLowerCase());
        for(var m in matches) {
          print(m.start);
        }
        String html = organization.name.replaceAll(searchText, '<em>${searchText}</em>');
        resultsList.children.add(liOrganization
            ..innerHtml = html);
      }
    }
  }

  void previousElement() {
    if(!withDropDown) {
      activeDropDown();
    } else if(highlightedIndex > 0) {
      highlightedIndex -= 1;
      highlightElement();
    }
  }

  void registerEventHandlers() {
    event.bus.on(event.organizationChanged).listen((model.Organization org) {
      organization = org;
      //updateSelected();
    });

    event.bus.on(event.organizationListChanged).listen((model.OrganizationList list) {
      organizationList = list;
    });

    searchBox.onKeyDown.listen((KeyboardEvent event) {
      int UP = 38, DOWN = 40;
      KeyEvent key = new KeyEvent.wrap(event);

      if(key.keyCode == UP) {
        previousElement();
        event.preventDefault();

      } else if(key.keyCode == DOWN) {
        nextElement();
        event.preventDefault();
      }
    });

    searchBox.onKeyUp.listen((KeyboardEvent event) {
      int TAB = 9, ENTER = 13, SHIFT = 16, CTRL = 17, ALT = 18, ESC = 27;
      KeyEvent key = new KeyEvent.wrap(event);

      if(key.keyCode == ESC) {
        if(withDropDown) {
          deactiveDropDown();
        } else {
          clearSelection();
        }
      } else if(key.keyCode == TAB   ||
                key.keyCode == SHIFT ||
                key.keyCode == CTRL  ||
                key.keyCode == ALT) {
        //NOTHING
      } else if(key.keyCode == ENTER) {
        takeSelected();

      } else {
        preformSearch(searchBox.value);
        highlightElement();
        activeDropDown();
      }
    });

    searchBox.onClick.listen((e) {
      preformSearch(searchBox.value);
    });

    searchBox.onFocus.listen((e) {
      print('CompanySelector searchBox onFocus');
      activeElement();
    });

    searchBox.onBlur.listen((e) {
      print('CompanySelector onBlur');
      deactiveElement();
      deactiveDropDown();
    });

    element.querySelector('.chosen-single')
      ..onClick.listen((e) {
        print('CompanySelector chosen-single.onClick');
        activeDropDown();
        highlightElement();
        searchBox.focus();
      });
  }

  void selection(Event e) {
    SelectElement element = e.target;

    try {
      int id = int.parse(element.value);

      storage.getOrganization(id).then((model.Organization org) {
        event.bus.fire(event.organizationChanged, org);
        log.debug('CompanySelector._selection updated organization to ${organization}');

      }).catchError((error) {
        event.bus.fire(event.organizationChanged, model.nullOrganization);
        log.critical('CompanySelector._selection storage.getOrganization failed with ${error}');

      });
    } on FormatException {
      event.bus.fire(event.organizationChanged, model.nullOrganization);
      log.critical('CompanySelector._selection storage.getOrganization SelectElement has bad value: ${element.value}');
    }
  }

  void takeSelected() {
    int elementIndex = 0;
    for(LIElement item in resultsList.children) {
      if(elementIndex == highlightedIndex) {
        selectedItemIndex = highlightedIndex;
        companyselectortext.text = item.text;
        deactiveDropDown();
        break;
      }
      elementIndex += 1;
    }
  }

  void updateSourceList() {
    ulOrganizationList.clear();
    int index = 0;
    for(var org in organizationList) {
      var myIndex = index;
      ulOrganizationList.add(new LIElement()
        ..classes.add('active-result')
        ..value = org.id
        ..attributes['index'] = index.toString()
        ..onClick.listen((_) {
          highlightedIndex = myIndex;
          takeSelected();
          //TODO Select this company.
        })
        ..onMouseOver.listen((_) {
          print('Mouse over ${myIndex}');
          highlightedIndex = myIndex;
          highlightElement();
        })
      );
      index += 1;
    }
  }
}
