import 'mediator_message.dart';
import 'mediator.dart';

abstract class MediatorHandler<R, TMessage extends MediatorMessage<R>> {
  Future<R> handle(TMessage message, Mediator mediator);
}