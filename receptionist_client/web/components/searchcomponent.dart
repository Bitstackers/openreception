part of components;


/*
 * SetViewedObject(T obj) // Writes to _selectedElementText, but don't find it in the DataList. 
 *                             Saved to CurrentObject, and find it in the list when the component is activated.
 * UpdateDataList(List<T> list) // saves reference to list in a new variable for UpdatedLists. On next open reload Datalist with UpdatedList.
 * 
 */

typedef bool Where<T>(T element, String searchText);
typedef String ElementToString<T>(T element, String searchText);
typedef void ElementInvokation<T>(T element);
typedef bool Equality<T>(T x, T y);
typedef void callback();

class SearchComponent<T> {
  callback _whenClearSelection = () {};
  void set whenClearSelection(callback function) {
    if(function != null) {
      _whenClearSelection = function;
    }
  }

  /**
   * Given an [_element] and the [searchText] tells whether the element gets displayed.
   */
  Where<T> _searchFilter = (T element, String searchText) => element.toString().contains(searchText);
  void set searchFilter(Where<T> function) {
    if(function != null) {
      _searchFilter = function;
    }
  }

  /**
   * Specifies how the [_element] gets displayed.
   * [searchText] can be used to highlight the reason the element is displayed.
   */
  ElementToString<T> _listElementToString = (T element, String searchText) {
    if(searchText == null || searchText.isEmpty) {
      return element.toString();
    } else {
      String text = element.toString();
      int matchIndex = text.toLowerCase().indexOf(searchText.toLowerCase());
      String before  = text.substring(0, matchIndex);
      String match   = text.substring(matchIndex, matchIndex + searchText.length);
      String after   = text.substring(matchIndex + searchText.length, text.length);
      return '${before}<em>${match}</em>${after}';
    }
  };
  void set listElementToString(ElementToString<T> function) {
    if(function != null) {
      _listElementToString = function;
    }
  }

  /**
   * When a element gets selected.
   */
  ElementInvokation<T> _selectedElementChanged = print;
  void set selectedElementChanged(ElementInvokation<T> function) {
    if(function != null) {
      _selectedElementChanged = function;
    }
  }

               DivElement      _container;
               Context         _context;
               List<T>         _dataList          = new List<T>();
               DivElement      _element;
               bool            _hasFocus          = false;
               LIElement       _highlightedLi;
  static const String           liIdTag           = 'data-index';
               List<LIElement> _list              = new List<LIElement>();
               UListElement    _resultsList;
               InputElement    _searchBox;
               String          _searchPlaceholder = 'Make a Search';
               SpanElement     _selectedElementText;
               bool            _withDropDown      = false;

  void set searchPlaceholder (String value) {
    if(_selectedElementText.text == _searchPlaceholder) {
      _selectedElementText.text = value;
    }
    _searchPlaceholder = value;
  }

  SearchComponent(DivElement this._element, Context this._context, String inputId) {
    String html = '''
    <div class="chosen-container chosen-container-single">
      <a class="chosen-single" tabindex="-1">
        <span></span>
        <div><b></b></div>
      </a>
      <div class="chosen-drop">
        <div class="chosen-search">
          <input id="${inputId}" type="text" autocomplete="off"></input>
        </div>
        <ul class="chosen-results"></ul>
      <div>
    </div>
    ''';

    _container           = new DocumentFragment.html(html).querySelector('.chosen-container');
    _selectedElementText = _container                     .querySelector('.chosen-single > span');
    _searchBox           = _container                     .querySelector('.chosen-search > input');
    _resultsList         = _container                     .querySelector('.chosen-results');
    _element.children.add(_container);

    _selectedElementText.text = _searchPlaceholder;

    registerEventHandlers();
  }

  void showDropDown() {
    _container.classes.add('chosen-with-drop');
    _withDropDown = true;
  }

  void Aclear() {
    closeDropDown();
    _searchBox.value = '';
    _selectedElementText.text = _searchPlaceholder;
    performSearch('');
  }
  
//  void clear() {
//    _searchBox.value = '';
//  }

  //TODO START XXX HACK If we notice the outside, then eventbus complains about making an event while another event is active.
  void clearSelection() {
    _selectedElementText.text = _searchPlaceholder;
    //_whenClearSelection();
  }   
  void _clearSelection() {
    _selectedElementText.text = _searchPlaceholder;
    _whenClearSelection();
  }
  // TODO END
  
  void closeDropDown() {
    _container.classes.remove('chosen-with-drop');
    _withDropDown = false;
  }
  

  /**
  * Adjust the scollbar to keep the highlighted list element visible.
  */
  void _makeElementVisible() {
    if(_highlightedLi != null) {
      if(_highlightedLi.offsetTop < _resultsList.scrollTop) {
        _resultsList.scrollTop = _highlightedLi.offsetTop;

      } else if(_resultsList.scrollTop + _resultsList.clientHeight - _highlightedLi.clientHeight <= _highlightedLi.offsetTop) {
        _resultsList.scrollTop = _highlightedLi.offsetTop + _highlightedLi.clientHeight - _resultsList.clientHeight;
      }
    }
  }

  /**
   * Highlights the given LIElement
   */
  void _highlightElement(LIElement li) {
    if(_highlightedLi != null) {
      _highlightedLi.classes.remove('highlighted');
    }

    if(li != null) {
      li.classes.add('highlighted');
      _highlightedLi = li;
    }

    _makeElementVisible();
  }

  void _nextElement() {
    if(!_withDropDown) {
      showDropDown();
    } else {
      if(_highlightedLi == null) return;
      LIElement newHighlight = _highlightedLi.nextElementSibling;
      if(newHighlight != null) {
        _highlightElement(newHighlight);
      }
    }
  }

  /**
   * Populates the [resultList] based on [searchText] and highlights an element.
   */
  void performSearch(String searchText) {
    _resultsList.children.clear();
    for(var li in _list) {
      int index = int.parse(li.attributes[liIdTag]);
      T dataElement = _dataList[index];

      if(_searchFilter(dataElement, searchText)) {
        _resultsList.children.add(li..innerHtml = _listElementToString(dataElement, searchText));
      }
    }

    if(_resultsList.children.isNotEmpty && !_resultsList.children.contains(_highlightedLi)) {
      _highlightElement(_resultsList.children.first);
    } else {
      _makeElementVisible();
    }
  }

  void _previousElement() {
    if(!_withDropDown) {
      showDropDown();
      } else {
      LIElement newHighlight = _highlightedLi.previousElementSibling;
      if(newHighlight != null) {
        _highlightElement(newHighlight);
      }
    }
  }

  void selectElement(T element, [Equality equalFunction]) {
    int index;
    for(int i = 0; i < _dataList.length; i++) {
      T item = _dataList[i];
      if(equalFunction != null) {
        if(equalFunction(item, element)) {
          index = i;
        }
      } else {
        if(item == element) {
          index = i;
        }
      }
    }

    if(index != null) {
      _highlightElement(_list[index]);
      closeDropDown();
      _searchBox.value = '';
      _selectedElementText.text = _listElementToString(_dataList[index], null);
    }
  }

  void registerEventHandlers() {    
    event.bus.on(event.keyUp).listen((_) { 
      if(_hasFocus) {
        _previousElement();
      }
    });
    
    event.bus.on(event.keyDown).listen((_) { 
      if(_hasFocus) {
        _nextElement();
      }
    });
    
    event.bus.on(event.keyEnter).listen((_) {
      if(_hasFocus &&_withDropDown) {
        _activateSelectedElement(_highlightedLi);
      }
    });
    
    event.bus.on(event.keyEsc).listen((_) {
      if(_hasFocus) {
        Aclear();
        _whenClearSelection();
      }
    });
    
    _searchBox.onInput.listen((Event e) {
      performSearch(_searchBox.value);
      showDropDown();
    });
    
    _container.querySelector('.chosen-single').onClick.listen((_) {
      event.bus.fire(event.locationChanged, new nav.Location(_context.id, _element.id, _searchBox.id));
      if(_withDropDown) {
        closeDropDown();
      } else {
        showDropDown();
        _searchBox.focus();
      }
    });
    
    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.setFocusState(_element, _searchBox);
      if(!active) {
        closeDropDown();
        _searchBox.value = '';
        performSearch('');
      }
      _hasFocus = active;
    });
  }

  /**
  * Make the highlighted element, the selected, and tell rest of bob about it.
  */
  void _activateSelectedElement(LIElement li) {
    if(li == null) return;
    int index = int.parse(li.attributes[liIdTag]);
    T dataElement = _dataList[index];
    _selectedElementText.text = _listElementToString(dataElement, null);

    closeDropDown();
    _searchBox.value = '';
    performSearch('');

    _selectedElementChanged(dataElement);
  }

  void updateSourceList(List<T> newList) {
    log.debug('SearchComponent. updateSourceList. numberOfElements: ${newList.length}');
    _clearSelection();
    _dataList = newList;
    _list.clear();
    for(int i = 0; i < _dataList.length; i++) {
      T dataElement = _dataList[i];
      LIElement myLi;
      myLi = new LIElement()
        ..classes.add('active-result')
        ..attributes[liIdTag] = i.toString()
        ..onMouseOver.listen((_) => _highlightElement(myLi))
        ..onMouseDown.listen((_) {
          _activateSelectedElement(myLi);
          _container.classes.add('chosen-container-active');
          new Future(_searchBox.focus);
        });

      _list.add(myLi);
    }
    performSearch(_searchBox.value);
  }
}