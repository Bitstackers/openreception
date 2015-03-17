library adaheads.server.view.useridentity;

import 'dart:convert';

import '../model.dart';

String userIdentityAsJson(UserIdentity userIdentity) =>
    JSON.encode(_userIdentityAsJsonMap(userIdentity));

String listUserIdentityAsJson(List<UserIdentity> userIdentities) =>
    JSON.encode({'identities':_listUserIdentityAsJsonList(userIdentities)});

String userIdentityIdAsJson(String id) => JSON.encode({'identity': id});

Map _userIdentityAsJsonMap(UserIdentity userIdentity) => userIdentity == null ? {} :
    {'identity'  : userIdentity.identity,
     'user_id'   : userIdentity.user_id};

List _listUserIdentityAsJsonList(List<UserIdentity> userIdentities) =>
    userIdentities.map(_userIdentityAsJsonMap).toList();
