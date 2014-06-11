library adaheads.server.logger;

Logger logger = new Logger();

class Logger {
  void debug(message) => print('[DEBUG] $message');
  void error(message) => print('[ERROR] $message');
  void critical(message) => print('[CRITICAL] $message');
}
