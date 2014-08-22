library openreception.storage;

import 'dart:async';

import 'model.dart' as Model;

part 'storage/storage-message.dart';
part 'storage/storage-message_queue.dart';
part 'storage/storage-user.dart';

class StorageException implements Exception {}

class NotFound implements StorageException {

  final String message;
  const NotFound([this.message = ""]);

  String toString() => "NotFound: $message";
}


class SaveFailed implements StorageException {

  final String message;
  const SaveFailed([this.message = ""]);

  String toString() => "SaveFailed: $message";
}

class Forbidden implements StorageException {

  final String message;
  const Forbidden([this.message = ""]);

  String toString() => "Forbidden: $message";
}

class NotAuthorized implements StorageException {

  final String message;
  const NotAuthorized([this.message = ""]);

  String toString() => "NotAuthorized: $message";
}

class ClientError implements StorageException {

  final String message;
  const ClientError([this.message = ""]);

  String toString() => "ClientError: $message";
}

class ServerError implements StorageException {

  final String message;
  const ServerError([this.message = ""]);

  String toString() => "ServerError: $message";
}
