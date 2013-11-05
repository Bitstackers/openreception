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

        LIElement selectedLi;
        LIElement highlightedLi;

  CompanySelector(DivElement this.element) {
    element.classes.addAll(['chosen-container','chosen-container-single']);

    String html = '''
      <a class="chosen-single" tabindex="-1">
        <span id="companyselectortext"></span>
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

    companyselectortext.text = organizationSearchPlaceholder;

    initialFill();
    registerEventHandlers();
  }

  void activateDropDown() {
    if(!withDropDown) {
      element.classes.add('chosen-with-drop');
      withDropDown = true;
    }
  }

  void activateElement() {
    element.classes.toggle('chosen-container-active', true);
  }

  void clearSelection() {
    companyselectortext.text = organizationSearchPlaceholder;
  }

  void deactivateDropDown() {
    //print('deactiveDropDown');
    if(withDropDown) {
      element.classes.remove('chosen-with-drop');
      withDropDown = false;
    }
  }

  void deactivateElement() {
    element.classes.toggle('chosen-container-active', false);
  }

  void highlightElement(LIElement li) {
    print('highlightElement()');
    if(highlightedLi != null) {
      highlightedLi.classes.toggle('highlighted', false);
    }

    if(li != null) {
      li.classes.toggle('highlighted', true);
    }

    highlightedLi = li;
    fixScroll();
  }

  void fixScroll() {
    if(highlightedLi != null) {
      if(highlightedLi.offsetTop < resultsList.scrollTop) {
        resultsList.scrollTop = highlightedLi.offsetTop;

      } else if(resultsList.scrollTop + resultsList.clientHeight - highlightedLi.clientHeight <= highlightedLi.offsetTop) {
        resultsList.scrollTop = highlightedLi.offsetTop + highlightedLi.clientHeight - resultsList.clientHeight;
      }
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

  bool isChildOf(Element child, Element parent) {
    if(child.parent == parent) {
      return true;
    } else if(child.parent != null) {
      return isChildOf(child.parent, parent);
    } else {
      return false;
    }
  }

  void nextElement() {
    if(!withDropDown) {
      activateDropDown();
    } else {
      LIElement newHighlight = highlightedLi.nextElementSibling;
      print('nextElement: ${newHighlight}');
      if(newHighlight != null) {
        highlightElement(newHighlight);
      }
    }
  }

  /**
   * Makes a new liste filtered base on [searchText], and highlights the right element.
   */
  void preformSearch(String searchText) {
    resultsList.children.clear();
    for(var liOrganization in ulOrganizationList) {
      String organizationName = liOrganization.attributes['originalname'];
      if(searchText.isEmpty) {
        resultsList.children.add(liOrganization
            ..innerHtml = organizationName);

      } else if(organizationName.toLowerCase().contains(searchText.toLowerCase())) {
        int matchIndex = organizationName.toLowerCase().indexOf(searchText.toLowerCase());
        String before = organizationName.substring(0, matchIndex);
        String match = organizationName.substring(matchIndex, matchIndex + searchText.length);
        String after = organizationName.substring(matchIndex + searchText.length, organizationName.length);

        String html = '${before}<em>${match}</em>${after}';
        resultsList.children.add(liOrganization
            ..innerHtml = html);
      }
    }

    if(!resultsList.children.contains(highlightedLi) && resultsList.children.isNotEmpty) {
      highlightElement(resultsList.children.first);
    } else {
      fixScroll();
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
          deactivateDropDown();
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
        activateDropDown();
      }
    });

    searchBox.onClick.listen((e) {
      preformSearch(searchBox.value);
    });

    searchBox.onFocus.listen((e) {
      print('CompanySelector searchBox onFocus');
      activateElement();
    });

    searchBox.onBlur.listen((FocusEvent e) {
      print('searchBox onBlur');
      print('relatedTarget: ${e.relatedTarget}');

//      if(e.relatedTarget != null && e.relatedTarget is AnchorElement){
//        AnchorElement relatedTarget = e.relatedTarget;
//        if(relatedTarget.classes.contains('chosen-single')) {
//          searchBox.focus();
//        }
      if(e.relatedTarget != null && isChildOf(e.relatedTarget, element)) {
        print('------------------------------------------------------------');
        searchBox.focus();
      } else {
        deactivateElement();
        deactivateDropDown();
      }
    });

    element.querySelector('.chosen-single')
      ..onMouseDown.listen((e) {
        print('CompanySelector chosen-single.onClick');
        if(withDropDown) {
          print('CompanySelector chosen-single.onClick DEACTIVATE');
          deactivateDropDown();
        } else {
          activateElement();
          activateDropDown();
          searchBox.focus();
        }
      });
  }

  /**
   * Takes the highlighted element, and collapses the dropdown.
   */
  void takeSelected() {
    selectedLi = highlightedLi;
    companyselectortext.text = selectedLi.attributes['originalname'];
    deactivateDropDown();
    searchBox.value = '';
    preformSearch('');

    //var basicOrganization = organizationList.firstWhere((bOrg) => bOrg.id == selectedLi.value, orElse: null);
    storage.getOrganization(selectedLi.value)
      .then((model.Organization organization) {
        event.bus.fire(event.organizationChanged, organization);
      })
      .catchError((e) {
        log.error('CompanySelector: The company selected was not found');
      });
  }

  void updateSourceList() {
    ulOrganizationList.clear();
    for(var org in organizationList) {
      LIElement myLi = new LIElement();
      myLi
        ..classes.add('active-result')
        ..value = org.id
        ..attributes['originalname'] = org.name
        ..onMouseDown.listen((_) {
          print('CLICK ${org.id}');
          takeSelected();
          activateElement();
          new Future(searchBox.focus);
          //TODO Select this company.
        })
        ..onMouseOver.listen((_) {
          print('Mouse over ${myLi.value}');
          highlightElement(myLi);
        })
        ..style.marginBottom = '1px';
      ulOrganizationList.add(myLi);
    }
  }
}
