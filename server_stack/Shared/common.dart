library common;

void log(message) => print(message);

String datetimeToJson(DateTime time) {
  //TODO We should find a uniformed format.
  return time.toString(); 
}
