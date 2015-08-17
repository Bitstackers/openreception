library adaheads.server.view.dialplantemplate;

import 'dart:convert';

import 'package:openreception_framework/model.dart';

String dialplanTemplateListAsJson(List<DialplanTemplate> list) =>
    JSON.encode({'templates': _dialplanTemplateListAsJsonList(list)});

Map _dialplanTemplateAsJsonMap(DialplanTemplate template) => template == null ? {} :
    {'id': template.id,
     'template': template.template};

List _dialplanTemplateListAsJsonList(List<DialplanTemplate> templates) =>
    templates.map(_dialplanTemplateAsJsonMap).toList();
