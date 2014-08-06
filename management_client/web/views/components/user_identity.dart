part of user.view;

class IdentityContainer {
  List<UserIdentity> _identities;
  UListElement _ul;

  IdentityContainer(UListElement this._ul);

  LIElement _makeIdentityNode(UserIdentity identity) {
    LIElement li = new LIElement();

    ImageElement deleteButton = new ImageElement(src: '/image/tp/red_plus.svg')
      ..classes.add('small-button')
      ..onClick.listen((_) {
      _ul.children.remove(li);
    });

    SpanElement content = new SpanElement()
      ..text = identity.identity;
    InputElement editBox = new InputElement(type: 'text');

    editableSpan(content, editBox);

    li.children.addAll([deleteButton, content, editBox]);
    return li;
  }

  InputElement _makeInputForNewItem() {
    InputElement newItem = new InputElement(type: 'text');
    newItem
      ..placeholder = 'Tilføj ny...'
      ..onKeyPress.listen((KeyboardEvent event) {
        KeyEvent key = new KeyEvent.wrap(event);
        if (key.keyCode == Keys.ENTER) {
          String item = newItem.value;
          newItem.value = '';

          LIElement li = _makeIdentityNode(new UserIdentity()..identity = item);
          int index = _ul.children.length - 1;
          _ul.children.insert(index, li);
        } else if (key.keyCode == Keys.ESCAPE) {
          newItem.value = '';
        }
      });
    return newItem;
  }

  void _populateUL(List<UserIdentity> identities) {
    InputElement newItem = _makeInputForNewItem();

    this._identities = identities;
    _ul.children
      ..clear()
      ..addAll(identities.map(_makeIdentityNode))
      ..add(new LIElement()..children.add(newItem));
  }

  Future saveChanges(int userId) {
    List<String> foundIdentities = [];

    for(LIElement item in _ul.children) {
      SpanElement span = item.children.firstWhere((i) => i is SpanElement, orElse: () => null);
      if(span != null) {
        String context = span.text;
        foundIdentities.add(context);
      }
    }

    List<Future> worklist = new List<Future>();

    //Inserts
    for(String identity in foundIdentities) {
      if(!_identities.any((UserIdentity i) => i.identity == identity)) {
        //Insert Identity
        Map data = {'identity': identity};
        worklist.add(request.createUserIdentity(userId, JSON.encode(data)).catchError((error, stack) {
          log.error('Tried to create a user identity. UserId: "${userId}". Identity: "${JSON.encode(data)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Deletes
    for(UserIdentity identity in _identities) {
      if(!foundIdentities.any((String i) => i == identity.identity)) {
        //Delete Identity
        worklist.add(request.deleteUserIdentity(userId, identity.identity)
            .catchError((error, stack) {
          log.error('Tried to delete user identity. UserId: "${userId}". Identity: "${JSON.encode(identity.identity)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }
    return Future.wait(worklist);
  }

  Future showIdentities(int userId) {
    return request.getUserIdentities(userId).then((List<UserIdentity> identities) {
      _populateUL(identities);
    });
  }

  void showNewUsersIdentities() {
    _populateUL([]);
  }
}
