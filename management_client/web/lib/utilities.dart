library utilities;

/** Makes a third list containing the content of the two lists.*/
List union(List aList, List bList) {
  List cList = new List();
  cList.addAll(aList);
  cList.addAll(bList);
  return cList;
}
