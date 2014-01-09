library utilities.common;

void log(message) => print(message);

String datetimeToJson(DateTime time) {
  //TODO We should find a format.
  return time.toString(); 
}
