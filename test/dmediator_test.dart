import 'package:dmediator/src/core/generic_mediator.dart';
import 'package:dmediator/src/exceptions/mediator_handler_not_linked.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks/fake_message.dart';

void main() {
  group('GenericMediator - Link Handler', () {
    test('Message will be sent to linked handler by Mediator', () async {
      // Arrange
      final mediator = GenericMediator();
      final handler = MockMediatorHandler<String, FakeMessage>();
      final message = FakeMessage();
      final expectedString = "Lorem ipsum";

      when(() => handler.handle(message, mediator))
          .thenAnswer((invocation) async => expectedString);

      // Act
      mediator.linkHandler<FakeMessage>(handler);
      final result = await mediator.send(message);

      // Assert
      verify(() => handler.handle(message, mediator)).called(1);
      expect(result, equals(expectedString));
    });

    test(
        "When handler not linked, mediator will throw HandlerNotLinkedException",
        () {
      // Arrange
      final mediator = GenericMediator();
      final message = FakeMessage();

      // Act & Assert
      final resultFuture = mediator.send(message);

      expect(resultFuture,
          throwsA(TypeMatcher<MediatorHandlerNotLinkedException>()));
    });

    test(
        "WHEN: Handler is linked AND perform new handler link without override flag;"
        "THAN: New handler link will not succeed",
        () async {
          // Arrange ----------------------------------------------------
          final mediator = GenericMediator();
          final firstHandler = MockMediatorHandler<String, FakeMessage>();
          final newHandler = MockMediatorHandler<String, FakeMessage>();

          final message = FakeMessage();

          when(() => firstHandler.handle(message, mediator)).thenAnswer((_) async => "no override");
          when(() => newHandler.handle(message, mediator)).thenAnswer((_) async => "override");

          mediator.linkHandler(firstHandler);
          mediator.linkHandler(newHandler);

          // Act --------------------------------------------------------
          final result = await mediator.send(message);

          // Assert -----------------------------------------------------
          expect(result, equals("no override"));
        });

    test(
        "WHEN: Handler is linked AND perform new handler link with override flag;"
        "THEN: New handler will override previous handler link",
        () async {
          // Arrange ----------------------------------------------------
          final mediator = GenericMediator();
          final firstHandler = MockMediatorHandler<String, FakeMessage>();
          final newHandler = MockMediatorHandler<String, FakeMessage>();

          final message = FakeMessage();

          when(() => firstHandler.handle(message, mediator)).thenAnswer((_) async => "no override");
          when(() => newHandler.handle(message, mediator)).thenAnswer((_) async => "override");

          mediator.linkHandler(firstHandler);
          mediator.linkHandler(newHandler, override: true);

          // Act --------------------------------------------------------
          final result = await mediator.send(message);

          // Assert -----------------------------------------------------
          expect(result, equals("override"));
        });
  });
}
