class AppException implements Exception {
  final String? message;
  final String? prefix;

  AppException([this.message, this.prefix]);
  String toString() => '$prefix$message';
}

class NotFoundException extends AppException {
  NotFoundException([String? message]) : super(message, "Not Found: ");
}

class BadRequestException extends AppException {
  BadRequestException([String? message]) : super(message, 'Bad Request: ');
}

class FetchDataException extends AppException {
  FetchDataException([String? message]) : super(message, 'Unable to process: ');
}

class ApiNotRespondingException extends AppException {
  ApiNotRespondingException([String? message]) : super(message, 'Api not responded in time: ');
}

class UnAuthorizedException extends AppException {
  UnAuthorizedException([String? message]) : super(message, 'UnAuthorized request: ');
}

class InternalServerError extends AppException {
  InternalServerError([String? message]) : super(message, "Internal server error: ");
}

class InvalidRequestException extends AppException {
  InvalidRequestException([String? message]) : super(message, "Invalid Data: ");
}
