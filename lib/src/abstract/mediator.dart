import 'mediator_event.dart';
import 'mediator_message.dart';


abstract class Mediator {
  /// Emit event to listeners
  bool emit<TEvent extends MediatorEvent>(TEvent event);

  /// Observe specific event stream
  Stream<TEvent> observe<TEvent extends MediatorEvent>();

  /// Send message to service
  Future<R> send<R>(MediatorMessage<R> message);
}