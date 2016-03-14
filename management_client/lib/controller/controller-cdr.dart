part of management_tool.controller;

class Cdr {
  final Uri _host;
  final String _token;

  Cdr(Uri this._host, String this._token);

  Future<Map<String, dynamic>> entries(DateTime from, DateTime to) => null;

  Future<Map<String, dynamic>> summaries(DateTime from, DateTime to) => null;
}
