library adaheads.server.view.user;

import 'dart:convert';

import '../model.dart';

String userAsJson(User user) => JSON.encode(_userAsJsonMap(user));

String listUserAsJson(List<User> users) =>
    JSON.encode({'users':_listUserAsJsonList(users)});

String userIdAsJson(int id) => JSON.encode({'id': id});

Map _userAsJsonMap(User user) => user == null ? {} :
    {'id': user.id,
     'name': user.name,
     'extension': user.extension};

List _listUserAsJsonList(List<User> user) =>
    user.map(_userAsJsonMap).toList();


String userGroupAsJson(List<UserGroup> groups) =>
    JSON.encode({'groups': _listUserGroupsAsJsonList(groups)});

List<Map> _listUserGroupsAsJsonList(List<UserGroup> groups) =>
    groups.map(_userGroupAsJsonMap).toList();

Map _userGroupAsJsonMap(UserGroup group) =>
    {'id': group.id,
     'name': group.name};

