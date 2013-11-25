part of components;

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
  ElementInvokation<T> _elementSelected = print;
  void set elementSelected(ElementInvokation<T> function) {
    if(function != null) {
      _elementSelected = function;
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

  void clear() {
    closeDropDown();
    _searchBox.value = '';
    _selectedElementText.text = _searchPlaceholder;
  }

  void _clearSelection() {
    _selectedElementText.text = _searchPlaceholder;
    _whenClearSelection();
  }

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
    _searchBox.onKeyDown.listen((KeyboardEvent event) {
      KeyEvent key = new KeyEvent.wrap(event);

      switch(key.keyCode) {
        case Keys.UP:
          event.preventDefault();
          _previousElement();
          break;

        case Keys.DOWN:
          event.preventDefault();
          _nextElement();
          break;
      }
    });

    _searchBox.onKeyUp.listen((KeyboardEvent event) {
      KeyEvent key = new KeyEvent.wrap(event);

      switch(key.keyCode) {
        case Keys.ESC:
          if(_withDropDown) {
            closeDropDown();
          } else {
            _clearSelection();
          }
          break;

        case Keys.ENTER:
          _activateSelectedElement(_highlightedLi);
          break;

        case Keys.TAB:
        case Keys.SHIFT:
        case Keys.CTRL:
        case Keys.ALT:
          break;

        default:
          if(key.ctrlKey == false && key.altKey == false) {
            performSearch(_searchBox.value);
            showDropDown();
          }
      }
    });

    _searchBox.onClick.listen((_) {
      performSearch(_searchBox.value);
    });

    _searchBox.onFocus.listen((_) {
      _container.classes.add('chosen-container-active');
      if(!_hasFocus) {
        setFocus(_searchBox.id);
      }
    });

    _searchBox.onBlur.listen((FocusEvent e) {
      if(e.relatedTarget != null && isChildOf(e.relatedTarget, _container)) {
        _searchBox.focus();

      } else {
        _searchBox.value = '';
        performSearch('');
        _container.classes.remove('chosen-container-active');
        closeDropDown();
      }
    });

    _container.querySelector('.chosen-single')
      ..onMouseDown.listen((_) {
        if(_withDropDown) {
          closeDropDown();
        } else {
          _container.classes.add('chosen-container-active');
          showDropDown();
          _searchBox.focus();
        }
    });

    event.bus.on(event.focusChanged).listen((Focus value) {
      if(value.current == _searchBox.id && !_hasFocus) {
        _hasFocus = true;
        _searchBox.focus();

      } else if(value.current != _element.id) {
        _hasFocus = false;
      }
    });

    _context.registerFocusElement(_searchBox);
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

    _elementSelected(dataElement);
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