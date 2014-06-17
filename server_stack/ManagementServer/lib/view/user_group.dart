library adaheads.server.view.usergroup;

import 'dart:convert';

import '../model.dart';

String userGroupAsJson(List<UserGroup> groups) =>
    JSON.encode({'groups': _listUserGroupsAsJsonList(groups)});

List<Map> _listUserGroupsAsJsonList(List<UserGroup> groups) =>
    groups.map(_userGroupAsJsonMap).toList();

Map _userGroupAsJsonMap(UserGroup group) =>
    {'id': group.id,
     'name': group.name};
