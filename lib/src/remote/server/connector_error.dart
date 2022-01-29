part of theater.remote;

abstract class ConnectorError {}

class ConnectorConnectionError extends ConnectorError {}

class ConnectorAuthorizationTimeoutError extends ConnectorError {}

class ConnectorInvalidAuthorizationError extends ConnectorError {}

class ConnectorConnectionInterruptedError extends ConnectorError {}
