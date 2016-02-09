part of management_tool.view;

class UserIdentities {
  List<model.UserIdentity> _identities;
  final UListElement element = new UListElement();
  final controller.User _userController;
  final Logger _log = new Logger ('$_libraryName.UserIdentities');

  UserIdentities(this._userController);

  LIElement _makeIdentityNode(model.UserIdentity identity) {
    LIElement li = new LIElement();

    ImageElement deleteButton = new ImageElement(src: '/image/tp/red_plus.svg')
      ..classes.add('small-button')
      ..onClick.listen((_) {
        element.children.remove(li);
      });


    InputElement editBox = new InputElement(type: 'text')..value = identity.identity;


    li.children.addAll([deleteButton, editBox]);
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

  Future saveChanges(int userId) {
    List<String> foundIdentities = new List<String>();

    element.children.where((e) => e is LIElement).forEach((item) {
      SpanElement span = item.children
          .firstWhere((Element i) => i is SpanElement, orElse: () => null);
      if (span != null) {
        String context = span.text;
        foundIdentities.add(context);
      }
    });

    List<Future> worklist = new List<Future>();

    //Inserts
    for (String identity in foundIdentities) {
      if (!_identities
          .any((model.UserIdentity i) => i.identity == identity)) {
        model.UserIdentity newIdentity = new model.UserIdentity.empty()
          ..identity = identity
          ..userId = userId;

        //Insert Identity
        worklist.add(
            _userController.addIdentity(newIdentity).catchError((error, stack) {
          _log.severe(
              'Tried to create a user identity. UserId: "${userId}". Identity: "$identity" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Deletes
    for (model.UserIdentity identity in _identities) {
      if (!foundIdentities.any((String i) => i == identity.identity)) {
        //Delete Identity
        worklist.add(
            _userController.removeIdentity(identity).catchError((error, stack) {
          _log.severe(
              'Tried to delete user identity. UserId: "${userId}". Identity: "${(identity.toJson())}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }
    return Future.wait(worklist);
  }

  Future showIdentities(int userId) {
    return _userController
        .identities(userId)
        .then((Iterable<model.UserIdentity> identities) {
      _populateUL(identities.toList());
    });
  }

  void showNewUsersIdentities() {
    _populateUL(new List<model.UserIdentity>());
  }
}
