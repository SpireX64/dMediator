class MediatorHandlerNotLinkedException implements Exception {
  late String _messageTypeName;

  MediatorHandlerNotLinkedException(Type messageType) {
    _messageTypeName = messageType.toString();
  }

  @override
  String toString() {
    return "$runtimeType: Can't find linked handler for message type <$_messageTypeName>";
  }
}