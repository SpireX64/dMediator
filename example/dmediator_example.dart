import 'package:dmediator/dmediator.dart';

void main() async {
  // Create generic mediator instance
  final mediator = GenericMediator();

  // Link some handler or handler factory to mediator
  mediator.linkHandler(AnotherMessageHandler());
  mediator.linkHandlerFactory(() => SomeMessageHandler());

  // Send async message to linked handler
  var result = await mediator.send(SomeMessage("Hello"));
  print(result);

  // Observe some typed broadcast event
  final subscription =
    mediator.observe<AuthenticationEvent>()
      .where((event) => event.isAdmin) // Filter events
      .map((event) => "Admin '${event.userName}' is log-in")
      .listen((text) {
        print(text);
      });

  final anotherSubscription =
    mediator.observe<AuthenticationEvent>()
      .map((event) => "Auth: ${event.userName}")
      .listen((text) { print(text); });

  // Emit some events to mediator
  mediator.emit(AuthenticationEvent("SomeGuy", false));
  mediator.emit(AuthenticationEvent("Administrator", true));

  // Unsubscribe anytime
  subscription.cancel();
  anotherSubscription.cancel();
}




class SomeMessage implements MediatorMessage<String> {
  final String text;
  SomeMessage(this.text);
}
class SomeMessageHandler implements MediatorHandler<String, SomeMessage> {
  @override
  Future<String> handle(SomeMessage message, Mediator mediator) {
    return Future.value("Message: ${message.text}");
  }
}

class AnotherMessageHandler implements MediatorHandler<String, SomeMessage> {
  @override
  Future<String> handle(SomeMessage message, Mediator mediator) {
    return Future.value("Secret: ${message.text}");
  }

}

class AuthenticationEvent implements MediatorEvent {
  final String userName;
  final bool isAdmin;
  AuthenticationEvent(this.userName, this.isAdmin);
}