part of utilities.service;

abstract class Protocol {
  static final BROADCAST_RESOURCE = "/broadcast";
}

abstract class Notification {
  
  static final String className = '${libraryName}.Notification'; 

  static HttpClient client = new HttpClient();
  
  /**
   * Performs a broadcat via the notification server.
   */
  static Future broadcast(Map map, Uri host, String serverToken) {
    final String context = '${className}.broadcast';

    host = Uri.parse('${host}${Protocol.BROADCAST_RESOURCE}?token=${serverToken}');
    
    return client.postUrl(host)
      .then(( HttpClientRequest req ) {
        req.headers.contentType = new ContentType( "application", "json", charset: "utf-8" );
        //req.headers.add( HttpHeaders.CONNECTION, "keep-alive");
        req.write( JSON.encode( map ));
        return req.close();
      }).then(( HttpClientResponse res ) {
      res.transform(UTF8.decoder)
         .transform(new LineSplitter())
         .listen(
          (String line) {
            print('${line}');
          });
    }).catchError((error) => print("Bad things happened with your request! : ${error}"));    
  }
}

