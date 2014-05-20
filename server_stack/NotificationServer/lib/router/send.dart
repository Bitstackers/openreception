part of notificationserver.router;

/**
 * Send primitive. Expects the request body to be a JSON string with a list of recipients
 * in the 'recipients' field. The 'message' field is also mandatory for obvious reasons.  
 */
void handleSend (HttpRequest request) {
  extractContent(request).then((String content) {
    List<int> recipients = new List<int>(); 
    
    Map json;
    
    try {
      json = JSON.decode(content);
      (json['recipients'] as List).forEach((int item) => recipients.add(item));
      assert (json.containsKey("message"));
    } catch (exeption){
      clientError (request, "Malformed JSON body");
      return;
    }
    
    List delivery_status = new List();
    recipients.forEach((int uid) {
      if (clientRegistry[uid]!= null) {
        int count = 0;
        clientRegistry[uid].forEach((WebSocket clientSocket) {
          print ("Sending to user $uid");
          clientSocket.add(json['message']);
          count++;
        });
        delivery_status.add({'uid' : uid, 'sent' : count});
      } else {
        delivery_status.add({'uid' : uid, 'sent' : 0});
      }
        

    });
      
    writeAndClose(request, JSON.encode({"status" : "ok", "delivery_status" : delivery_status}));
  });
}
