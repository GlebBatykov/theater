part of theater.remote;

abstract class ConnectionError {}

class ConnectionInvalidAuthorizationError extends ConnectionError {}

class ConnectionAuthorizationTimeoutError extends ConnectionError {}

class ConnectionInterruptedError extends ConnectionError {}
