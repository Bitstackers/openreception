part of user.view;

class IdentityContainer {
  List<ORModel.UserIdentity> _identities;
  UListElement _ul;
  final Controller.User _userController;

  IdentityContainer(UListElement this._ul, Controller.User this._userController);

  LIElement _makeIdentityNode(ORModel.UserIdentity identity) {
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

          LIElement li = _makeIdentityNode(new ORModel.UserIdentity.empty()..identity = item);
          int index = _ul.children.length - 1;
          _ul.children.insert(index, li);
        } else if (key.keyCode == Keys.ESCAPE) {
          newItem.value = '';
        }
      });
    return newItem;
  }

  void _populateUL(List<ORModel.UserIdentity> identities) {
    InputElement newItem = _makeInputForNewItem();

    this._identities = identities;
    _ul.children
      ..clear()
      ..addAll(identities.map(_makeIdentityNode))
      ..add(new LIElement()..children.add(newItem));
  }

  Future saveChanges(int userId) {
    List<String> foundIdentities = new List<String>();

    for(LIElement item in _ul.children) {
      SpanElement span = item.children.firstWhere((Element i) => i is SpanElement, orElse: () => null);
      if(span != null) {
        String context = span.text;
        foundIdentities.add(context);
      }
    }

    List<Future> worklist = new List<Future>();

    //Inserts
    for(String identity in foundIdentities) {
      if(!_identities.any((ORModel.UserIdentity i) => i.identity == identity)) {
        ORModel.UserIdentity newIdentity = new ORModel.UserIdentity.empty()
          ..identity = identity
          ..userId = userId;

        //Insert Identity
        worklist.add(_userController.addIdentity(newIdentity).catchError((error, stack) {
          log.error('Tried to create a user identity. UserId: "${userId}". Identity: "$identity" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Deletes
    for(ORModel.UserIdentity identity in _identities) {
      if(!foundIdentities.any((String i) => i == identity.identity)) {

        //Delete Identity
        worklist.add(_userController.removeIdentity(identity)
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
    return _userController.identities(userId).then((Iterable<ORModel.UserIdentity> identities) {
      _populateUL(identities.toList());
    });
  }

  void showNewUsersIdentities() {
    _populateUL(new List<ORModel.UserIdentity>());
  }
}
