part of model;

class UIContactSelector extends UIModel {
  final DivElement _myRoot;

  UIContactSelector(DivElement this._myRoot) {
    _filter.onInput.listen(filter);
  }

  @override HtmlElement get _firstTabElement => _filter;
  @override HtmlElement get _focusElement    => _filter;
  @override HtmlElement get _lastTabElement  => _filter;
  @override HtmlElement get _root            => _myRoot;

  UListElement get _contactList => _root.querySelector('.generic-widget-list');
  InputElement get _filter      => _root.querySelector('.filter');

  /**
   * Add [items] to the contacts list.
   */
  set contacts(List<Contact> items) {
    items.forEach((Contact item) {
      String initials = item.name.trim().split(' ').fold('', (prev, element) => '${prev} ${element.substring(0,1)}');
      item._li.dataset['searchstring'] = '${initials}-${item.name}'.trim().toLowerCase();
      _contactList.append(item._li);
    });
  }

  /**
   * TODO (TL): Comment this..
   */
  void filter(_) {
    String searchTerm = _filter.value.trim();

    if(searchTerm.isNotEmpty) {

    }
  }

  /**
   * Return the selected [Contact] from [_contactList]
   * MAY return null if nothing is selected.
   */
  Contact getSelectedContact() {
    try {
      return new Contact.fromElement(_contactList.querySelector('.selected'));
    } catch (e) {
      print(e);
      return null;
    }
  }

  /**
   * Return the [Contact] the user clicked on.
   * MAY return null if the user did not click on an actual valid [Contact].
   */
  Contact getContactFromClick(MouseEvent event) {
    if(event.target is LIElement) {
      return new Contact.fromElement(event.target);
    }

    return null;
  }

  /**
   * Return the [index] [Contact] from [_contactList]
   * MAY return null if index does not exist in the list.
   */
  Contact getContactFromIndex(int index) {
    try {
      return new Contact.fromElement(_contactList.children[index]);
    } catch(e) {
      print(e);
      return null;
    }
  }

  /**
   * Return the mousedown click event stream for this widget.
   */
  Stream<MouseEvent> get onClick => _myRoot.onMouseDown;

  /**
   * Mark [contact] selected.
   */
  void markSelected(Contact contact) {
    if(contact != null) {
      _contactList.children.forEach((Element element) => element.classes.remove('selected'));
      contact._li.classes.add('selected');
      contact._li.scrollIntoView();
    }
  }

  /**
   * Return the [Contact] following the currently selected [Contact].
   * Return null if we're at last element.
   */
  Contact nextContactInList() {
    try {
      LIElement li = _contactList.querySelector('.selected').nextElementSibling;
      return li != null ? new Contact.fromElement(li) : null;
    } catch(e) {
      print(e);
      return null;
    }
  }

  /**
   * TODO (TL): comment this..
   */
  Stream<Event> get onInput => _filter.onInput;

  /**
   * Return the [Contact] preceeding the currently selected [Contact].
   * Return null if we're at first element.
   */
  Contact previousContactInList() {
    try {
      LIElement li = _contactList.querySelector('.selected').previousElementSibling;
      return li != null ? new Contact.fromElement(li) : null;
    } catch(e) {
      print(e);
      return null;
    }
  }
}

/**
 * A contact.
 * TODO (TL): Replace this with the actual object. This is just a placeholder.
 */
class Contact {
  LIElement _li = new LIElement()..tabIndex = -1;
  String    name;

  Contact(String this.name) {
    _li.text = name;
  }

  Contact.fromElement(LIElement element) {
    if(element != null && element is LIElement) {
      _li = element;
      name = _li.text;
    } else {
      throw new ArgumentError('element is not a LIElement');
    }
  }
}
