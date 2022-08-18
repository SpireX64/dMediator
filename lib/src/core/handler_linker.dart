import 'dart:math';

import 'package:dmediator/dmediator_abstract.dart';

class LinkerEntry<T> {
  T? _instance;
  T Function()? _factory;

  LinkerEntry.fromInstance(T instance) {
    _instance = instance;
  }

  LinkerEntry.fromFactory(T Function() factory) {
    _factory = factory;
  }

  T getInstance() {
    if (_instance != null) return _instance!;
    if (_factory != null) return _factory!.call();
    throw StateError("Invalid LinkerEntry State");
  }
}

class HandlerLinker {
  final Map<Type, LinkerEntry> _links = {};

  bool _checkMessageLinked(Type messageType) {
    return _links.containsKey(messageType);
  }

  bool linkHandler<TMessage extends MediatorMessage<dynamic>>(
      MediatorHandler<dynamic, TMessage> handlerInstance,
      {bool override = false}) {
    if (!override && _checkMessageLinked(TMessage)) return false;
    _links[TMessage] = LinkerEntry.fromInstance(handlerInstance);
    return true;
  }

  bool linkHandlerFactory<TMessage extends MediatorMessage<dynamic>>(
      MediatorHandler<dynamic, TMessage> Function() handlerFactory,
      {bool override = false}
  ) {
    if (!override && _checkMessageLinked(TMessage)) return false;
    _links[TMessage] = LinkerEntry.fromFactory(handlerFactory);
    return true;
  }

  MediatorHandler<R, dynamic>? resolveHandler<R>(Type messageType) {
    final entry = _links[messageType];
    if (entry == null) return null;
    return entry.getInstance();
  }
}
