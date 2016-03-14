// part of management_tool.view;
//
// class Cdr {
//   final Logger _log = new Logger('$_libraryName.Messages');
//
//   Cdr();
//
//   List<DivElement> get content => [filter, totals, listing];
//
//   DivElement get filter => new DivElement()
//     ..style.border = 'solid 1px red'
//     ..style.marginLeft = '0.5em'
//     ..children = [
//       new InputElement()..placeholder = 'ISO8601 fra tidsstempel',
//       new InputElement()..placeholder = 'ISO8601 til tidsstempel',
//       new InputElement()..placeholder = 'type list | summary',
//       new InputElement()..placeholder = 'retning both | inbound | outbound',
//       new InputElement()..placeholder = 'reception id',
//       new InputElement()..placeholder = 'agent id',
//       new ButtonElement()
//         ..text = 'hent'
//         ..classes.add('create')
//         ..onClick.listen((_) {
//           print('CLICK!');
//         }),
//     ];
//
//   OListElement get listing => new OListElement()
//     ..style.border = 'solid 1px brown'
//     ..style.marginLeft = '0.5em'
//     ..style.flexGrow = '1'
//     ..text = 'listing';
//
//   DivElement get totals => new DivElement()
//     ..style.border = 'solid 1px blue'
//     ..style.marginLeft = '0.5em'
//     ..text = 'totals';
// }
