part of management_tool.view;

class UserIdentityChange {
  final Change type;
  final String identity;

  UserIdentityChange.add(this.identity) : type = Change.added;
  UserIdentityChange.remove(this.identity) : type = Change.deleted;

  /**
   *
   */
  @override
  String toString() => '$type, identity:$identity';
}

class UserIdentities {
  List<model.UserIdentity> _identities;
  final UListElement element = new UListElement();
  final controller.User _userController;
  final Logger _log = new Logger('$_libraryName.UserIdentities');

  Function onChange = () => null;

  UserIdentities(this._userController);

  LIElement _makeIdentityNode(model.UserIdentity identity) {
    LIElement li = new LIElement();

    ImageElement deleteButton = new ImageElement(src: '/image/tp/red_plus.svg')
      ..classes.add('small-button')
      ..onClick.listen((_) {
        element.children.remove(li);
        if (onChange != null) {
          onChange();
        }
      });

    InputElement editBox = new InputElement(type: 'text')
      ..value = identity.identity;

    li.children.addAll([editBox, deleteButton]);
    return li;
  }

  InputElement _makeInputForNewItem() {
    InputElement newItem = new InputElement(type: 'text');
    newItem
      ..placeholder = 'Tilføj ny...'
      ..onKeyPress.listen((KeyboardEvent event) {
        KeyEvent key = new KeyEvent.wrap(event);
        if (key.keyCode == Key.ENTER) {
          String item = newItem.value;
          newItem.value = '';

          if (onChange != null) {
            onChange();
          }

          LIElement li = _makeIdentityNode(
              new model.UserIdentity.empty()..identity = item);
          int index = element.children.length - 1;
          element.children.insert(index, li);
        } else if (key.keyCode == Key.ESCAPE) {
          newItem.value = '';
        }
      });
    return newItem;
  }

  void _populateUL(List<model.UserIdentity> identities) {
    InputElement newItem = _makeInputForNewItem();

    this._identities = identities;
    element.children
      ..clear()
      ..addAll(identities.map(_makeIdentityNode))
      ..add(new LIElement()..children.add(newItem));
  }

  Iterable<UserIdentityChange> changes() {
    final List<UserIdentityChange> changeList = [];
    List<String> foundIdentities = new List<String>();

    element.children.where((e) => e is LIElement).forEach((item) {
      InputElement li = item.children
          .firstWhere((Element i) => i is InputElement, orElse: () => null);
      if (li != null) {
        String context = li.value;
        foundIdentities.add(context);
      }
    });

    //Inserts
    for (String identity in foundIdentities) {
      if (!_identities.any((model.UserIdentity i) => i.identity == identity)) {
        if (identity.isNotEmpty) {
          changeList.add(new UserIdentityChange.add(identity));
        }
      }
    }

    //Deletes
    for (model.UserIdentity identity in _identities) {
      if (!foundIdentities.any((String i) => i == identity.identity)) {
        changeList.add(new UserIdentityChange.remove(identity.identity));
      }
    }
    return changeList;
  }

  /**
   *
   */
  void set identities(Iterable<model.UserIdentity> ids) {
    _identities = ids.toList(growable: false);
    _populateUL(_identities);
  }

  void showNewUsersIdentities() {
    _populateUL(new List<model.UserIdentity>());
  }
}
