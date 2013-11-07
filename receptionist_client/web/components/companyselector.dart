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
        SpanElement            companyselectortext;
        DivElement             container;
        DivElement             element;
        bool                   hasFocus = false;
        LIElement              highlightedLi;
        List<LIElement>        list = new List<LIElement>();
  final String                 organizationSearchPlaceholder = 'Søg efter en virksomhed';
        model.OrganizationList organizationList  = new model.OrganizationList();
        UListElement           resultsList;
        InputElement           searchBox;
        bool                   withDropDown = false;

        int tabIndex = 1;

  CompanySelector(DivElement this.element) {
    String html = '''
      <div class="chosen-container chosen-container-single">
        <a class="chosen-single" tabindex="-1">
          <span id="companyselectortext"></span>
          <div><b></b></div>
        </a>
        <div class="chosen-drop">
          <div class="chosen-search">
            <input id="company-selector-searchbar" type="text" autocomplete="off"></input>
          </div>
          <ul class="chosen-results"></ul>
      <div>
      </div>
    ''';

    container           = new DocumentFragment.html(html).querySelector('.chosen-container');
    companyselectortext = container                      .querySelector('#companyselectortext');
    searchBox           = container                      .querySelector('.chosen-search > input');
    resultsList         = container                      .querySelector('.chosen-results');
    element.children.add(container);

    companyselectortext.text = organizationSearchPlaceholder;

    initialFill();
    registerEventHandlers();
  }

  void activateDropDown() {
    container.classes.add('chosen-with-drop');
    withDropDown = true;
  }

  void activateTab() {
    searchBox.tabIndex = getTabIndex('company-selector-searchbar');
  }

  void deactivateTab() {
    searchBox.tabIndex = -1;
  }

  void clearSelection() {
    companyselectortext.text = organizationSearchPlaceholder;
    event.bus.fire(event.organizationChanged, model.nullOrganization);
  }

  void deactivateDropDown() {
    container.classes.remove('chosen-with-drop');
    withDropDown = false;
  }

  /**
   * Adjust the scollbar to keep the highlighted list element visible.
   */
  void makeElementVisible() {
    if(highlightedLi != null) {
      if(highlightedLi.offsetTop < resultsList.scrollTop) {
        resultsList.scrollTop = highlightedLi.offsetTop;

      } else if(resultsList.scrollTop + resultsList.clientHeight - highlightedLi.clientHeight <= highlightedLi.offsetTop) {
        resultsList.scrollTop = highlightedLi.offsetTop + highlightedLi.clientHeight - resultsList.clientHeight;
      }
    }
  }

  void highlightElement(LIElement li) {
    if(highlightedLi != null) {
      highlightedLi.classes.remove('highlighted');
    }

    if(li != null) {
      li.classes.add('highlighted');
      highlightedLi = li;
    }

    makeElementVisible();
  }

  void initialFill() {
    storage.getOrganizationList()
      .then((model.OrganizationList list) => organizationList = list)
      .catchError((error) => log.critical('CompanySelector._initialFill storage.getOrganizationList failed with ${error}'))
      .whenComplete(() {
        updateSourceList();
        performSearch(searchBox.value);
      });
  }

  void nextElement() {
    if(!withDropDown) {
      activateDropDown();
    } else {
      LIElement newHighlight = highlightedLi.nextElementSibling;
      if(newHighlight != null) {
        highlightElement(newHighlight);
      }
    }
  }

  /**
   * Populates the [resultList] based on [searchText] and highlights an element.
   */
  void performSearch(String searchText) {
    resultsList.children.clear();
    for(var li in list) {
      String name = li.attributes['data-originalname'];

      if(searchText.isEmpty) {
        resultsList.children.add(li..innerHtml = name);

      } else if(name.toLowerCase().contains(searchText.toLowerCase())) {
        int matchIndex = name.toLowerCase().indexOf(searchText.toLowerCase());
        String before  = name.substring(0, matchIndex);
        String match   = name.substring(matchIndex, matchIndex + searchText.length);
        String after   = name.substring(matchIndex + searchText.length, name.length);

        resultsList.children.add(li..innerHtml = '${before}<em>${match}</em>${after}');
      }
    }

    if(!resultsList.children.contains(highlightedLi) && resultsList.children.isNotEmpty) {
      highlightElement(resultsList.children.first);
    } else {
      makeElementVisible();
    }
  }

  void previousElement() {
    if(!withDropDown) {
      activateDropDown();
    } else {
      LIElement newHighlight = highlightedLi.previousElementSibling;
      if(newHighlight != null) {
        highlightElement(newHighlight);
      }
    }
  }

  void registerEventHandlers() {
    event.bus.on(event.organizationChanged).listen((model.Organization organization) {
      if(organization == model.nullOrganization) {
        deactivateDropDown();
        searchBox.value = '';
        companyselectortext.text = organizationSearchPlaceholder;
      } else {
        for(LIElement li in list) {
          if(li.value == organization.id) {
            highlightElement(li);
            deactivateDropDown();
            searchBox.value = '';
            companyselectortext.text = organization.name;
            break;
          }
        }
      }
    });

    searchBox.onKeyDown.listen((KeyboardEvent event) {
      KeyEvent key = new KeyEvent.wrap(event);

      switch(key.keyCode) {
        case Keys.UP:
          event.preventDefault();
          previousElement();
          break;

        case Keys.DOWN:
          print('COMPANY KEYBOARD');
          event.preventDefault();
          nextElement();
          break;
      }
    });

    searchBox.onKeyUp.listen((KeyboardEvent event) {
      KeyEvent key = new KeyEvent.wrap(event);

      switch(key.keyCode) {
        case Keys.ESC:
          if(withDropDown) {
            deactivateDropDown();
          } else {
            clearSelection();
          }
          break;

        case Keys.ENTER:
          activateSelectedOrganization(highlightedLi);
          break;

        case Keys.TAB:
        case Keys.SHIFT:
        case Keys.CTRL:
        case Keys.ALT:
          break;

        default:
          performSearch(searchBox.value);
          activateDropDown();
      }
    });

    searchBox.onClick.listen((e) {
      performSearch(searchBox.value);
    });

    searchBox.onFocus.listen((e) {
      container.classes.add('chosen-container-active');
      if(!hasFocus) {
        setFocus(element.id);
      }
    });

    searchBox.onBlur.listen((FocusEvent e) {
      if(e.relatedTarget != null && isChildOf(e.relatedTarget, container)) {
        searchBox.focus();

      } else {
        searchBox.value = '';
        performSearch('');
        container.classes.remove('chosen-container-active');
        deactivateDropDown();
      }
    });

    container.querySelector('.chosen-single')
      ..onMouseDown.listen((_) {
        if(withDropDown) {
          deactivateDropDown();
        } else {
          container.classes.add('chosen-container-active');
          activateDropDown();
          searchBox.focus();
        }
      });

    event.bus.on(event.focusChanged).listen((Focus value) {
      if(value.current == element.id && !hasFocus) {
        hasFocus = true;
        searchBox.focus();

      } else if(value.current != element.id) {
        hasFocus = false;
      }
    });
  }

  /**
   * Make the highlighted element, the selected, and tell rest of bob about it.
   */
  void activateSelectedOrganization(LIElement li) {
    companyselectortext.text = li.attributes['data-originalname'];

    deactivateDropDown();
    searchBox.value = '';
    performSearch('');

    storage.getOrganization(li.value)
      .then((model.Organization value) => event.bus.fire(event.organizationChanged, value))
      .catchError((_) => log.error('CompanySelector: The company selected was not found'));
  }

  void updateSourceList() {
    for(var org in organizationList) {
      LIElement myLi;
      myLi = new LIElement()
        ..classes.add('active-result')
        ..value = org.id
        ..attributes['data-originalname'] = org.name
        ..onMouseOver.listen((_) => highlightElement(myLi))
        ..onMouseDown.listen((_) {
            activateSelectedOrganization(myLi);
            container.classes.add('chosen-container-active');
            new Future(searchBox.focus);
          });

      list.add(myLi);
    }
  }
}
