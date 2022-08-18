import 'package:dmediator/src/core/handler_linker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'mocks/fake_message.dart';
import 'utils/ref.dart';


void main() {
  group("HandlerLinker", () {
    test("When handler not resolved (linked) returns null", () {
      // Arrange
      final linker = HandlerLinker();

      // Act
      final handler = linker.resolveHandler<String>(FakeMessage);

      // Assert
      expect(handler, equals(null));
    });

    test ("When handler linked, returns true", () {
      // Arrange
      final linker = HandlerLinker();
      final handler = MockMediatorHandler<String, FakeMessage>();

      // Act
      final isLinked = linker.linkHandler(handler);

      // Assert
      expect(isLinked, isTrue);
    });

    test("When handler already linked, on re-link returns false", () {
      // Arrange
      final linker = HandlerLinker();
      final handler = MockMediatorHandler<String, FakeMessage>();

      // Act
      final isLinked = linker.linkHandler(handler);
      final isReLinked = linker.linkHandler(handler);

      // Assert
      expect(isLinked, isTrue);
      expect(isReLinked, isFalse);
    });

    test("When handler already linked, on re-link with override returns true", () {
      // Arrange
      final linker = HandlerLinker();
      final handler = MockMediatorHandler<String, FakeMessage>();

      // Act
      final isLinked = linker.linkHandler(handler);
      final isReLinked = linker.linkHandler(handler, override: true);

      // Assert
      expect(isLinked, isTrue);
      expect(isReLinked, isTrue);
    });

    test("When resolve linked instance, returns same instance", () {
      // Arrange
      final linker = HandlerLinker();
      final handler = MockMediatorHandler<String, FakeMessage>();

      // Act
      linker.linkHandler(handler);
      final resolvedHandler = linker.resolveHandler<String>(FakeMessage);

      // Assert
      expect(resolvedHandler, equals(handler));
    });

    test("When 2+ handlers linked, resolve handler of message type", () {
      // Arrange
      final linker = HandlerLinker();
      final handlerA = MockMediatorHandler<String, FakeMessage>();
      final handlerB = MockMediatorHandler<int, AnotherFakeMessage>();
      linker.linkHandler(handlerA);
      linker.linkHandler(handlerB);

      // Act
      final resolvedHandlerA = linker.resolveHandler<String>(FakeMessage);
      final resolvedHandlerB = linker.resolveHandler<int>(AnotherFakeMessage);

      // Assert
      expect(resolvedHandlerA, equals(handlerA));
      expect(resolvedHandlerB, equals(handlerB));
    });
    
    test("When override instance, resolve last linked instance", () {
      // Arrange
      final linker = HandlerLinker();
      final handler = MockMediatorHandler<String, FakeMessage>();
      final newHandler = MockMediatorHandler<String, FakeMessage>();

      // Act
      linker.linkHandler(handler);
      linker.linkHandler(newHandler, override: true);
      final resolvedHandler = linker.resolveHandler<String>(FakeMessage);

      // Assert
      expect(resolvedHandler, isNot(equals(handler)));
      expect(resolvedHandler, equals(newHandler));
    });

    test("When link handler factory, its not to be called immediately", () {
      // Arrange
      final linker = HandlerLinker();

      final isFactoryCalled = Ref(false);
      factoryMock() {
        isFactoryCalled.value = true;
        return MockMediatorHandler<String, FakeMessage>();
      }

      // Act
      linker.linkHandlerFactory(factoryMock);

      // Assert
      expect(isFactoryCalled.value, isFalse);
    });



    test("When link handler factory, its called on resolve and returns handler instance", () {
      // Arrange
      final linker = HandlerLinker();
      final handler = MockMediatorHandler<String, FakeMessage>();

      final isFactoryCalled = Ref(false);
      factoryMock() {
        isFactoryCalled.value = true;
        return handler;
      }

      // Act
      linker.linkHandlerFactory(factoryMock);
      final resolvedHandler = linker.resolveHandler<String>(FakeMessage);

      // Assert
      expect(isFactoryCalled.value, isTrue);
      expect(resolvedHandler, equals(handler));
    });

    test("When handler already linked, next factory link will be fail", () {
      // Arrange
      final linker = HandlerLinker();
      final handlerA = MockMediatorHandler<String, FakeMessage>();
      final handlerB = MockMediatorHandler<String, FakeMessage>();

      final isFactoryCalled = Ref(false);
      factoryMock() {
        isFactoryCalled.value = true;
        return handlerB;
      }

      // Act
      final isLinkedHandlerA = linker.linkHandler(handlerA);
      final isLinkedHandlerFactoryB = linker.linkHandlerFactory(factoryMock);
      final resolvedHandler = linker.resolveHandler<String>(FakeMessage);

      // Assert
      expect(isLinkedHandlerA, isTrue);
      expect(isLinkedHandlerFactoryB, isFalse);
      expect(isFactoryCalled.value, isFalse);
      expect(resolvedHandler, handlerA);
    });

    test("When handler already linked, next factory link can override it", () {
      // Arrange
      final linker = HandlerLinker();
      final handlerA = MockMediatorHandler<String, FakeMessage>();
      final handlerB = MockMediatorHandler<String, FakeMessage>();

      final isFactoryCalled = Ref(false);
      factoryMock() {
        isFactoryCalled.value = true;
        return handlerB;
      }

      // Act
      final isLinkedHandlerA = linker.linkHandler(handlerA);
      final isLinkedHandlerFactoryB = linker.linkHandlerFactory(factoryMock, override: true);
      final resolvedHandler = linker.resolveHandler<String>(FakeMessage);

      // Assert
      expect(isLinkedHandlerA, isTrue);
      expect(isLinkedHandlerFactoryB, isTrue);
      expect(isFactoryCalled.value, isTrue);
      expect(resolvedHandler, handlerB);
    });
  });
}