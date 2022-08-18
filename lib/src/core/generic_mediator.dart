import 'dart:async';

import 'package:dmediator/dmediator_abstract.dart';
import 'package:dmediator/src/abstract/mediator_event.dart';
import 'package:dmediator/src/exceptions/mediator_abstract_observe.dart';

import 'handler_linker.dart';

class GenericMediator implements Mediator {
  final HandlerLinker _linker = HandlerLinker();
  final Map<Type, StreamController> _steamMap = {};

  @override
  Future<R> send<R>(MediatorMessage<R> message) {
    final handler = _linker.resolveHandler<R>(message.runtimeType);
    if (handler == null) {
      return Future.error(
          MediatorHandlerNotLinkedException(message.runtimeType));
    }
    return handler.handle(message, this);
  }

  GenericMediator linkHandler<TMessage extends MediatorMessage<dynamic>>(
      MediatorHandler<dynamic, TMessage> handler,
      {override = false}) {
    _linker.linkHandler(handler, override: override);
    return this;
  }

  GenericMediator linkHandlerFactory<TMessage extends MediatorMessage<dynamic>>(
      MediatorHandler<dynamic, TMessage> Function() handlerFactory,
      {override = false}) {
    _linker.linkHandlerFactory(handlerFactory, override: override);
    return this;
  }

  @override
  bool emit<TEvent extends MediatorEvent>(TEvent event) {
    if (!_steamMap.containsKey(TEvent)) return false;

    final controller = _steamMap[TEvent] as StreamController<TEvent>;
    if (!controller.hasListener) {
      controller.close();
      _steamMap.remove(TEvent);
      return false;
    }

    controller.add(event);
    return true;
  }

  @override
  Stream<TEvent> observe<TEvent extends MediatorEvent>() {
    if (TEvent == MediatorEvent) {
      throw MediatorAbstractObserveException();
    }

    StreamController<TEvent> controller;
    if (_steamMap.containsKey(TEvent)) {
      controller = _steamMap[TEvent] as StreamController<TEvent>;
    } else {
      controller = StreamController<TEvent>.broadcast();
      _steamMap[TEvent] = controller;
    }

    return controller.stream;
  }
}
