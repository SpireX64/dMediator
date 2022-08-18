import 'package:dmediator/src/abstract/mediator_event.dart';
import 'package:dmediator/src/core/generic_mediator.dart';
import 'package:dmediator/src/exceptions/mediator_abstract_observe.dart';
import 'package:test/test.dart';

import 'mocks/fake_event.dart';

void main() {
  group("Mediator Emitter", () {
    test(
        "WHEN: Emit event without listeners"
        "THEN: Event will not send", () {
      // Arrange
      final mediator = GenericMediator();

      // Act
      final eventWasSent = mediator.emit(FakeEvent());

      // Assert
      expect(eventWasSent, isFalse);
    });

    test(
        "WHEN: Emit event with listeners"
        "THEN: Listeners will be notified", () {
      // Arrange
      final mediator = GenericMediator();
      final fakeEvent = FakeEvent();

      mediator.observe<FakeEvent>().listen(expectAsync1(
            (event) {
              expect(event, equals(fakeEvent));
            },
            count: 1,
          ));

      // Act
      final eventWasSent = mediator.emit(fakeEvent);

      // Assert
      expect(eventWasSent, isTrue);
    });

    test(
      "WHEN: Observe same event stream many times"
          "THEN: Mediator will returns a same stream",
        () {
          final mediator = GenericMediator();
          var streamA = mediator.observe<FakeEvent>();
          var streamB = mediator.observe<FakeEvent>();

          expect(streamA == streamB, isTrue);
        });

    test(
        "WHEN: Try to observe abstract event 'MediatorEvent'"
        "THEN: Throws MediatorAbstractObserveException", () {
      final mediator = GenericMediator();

      expect(() => mediator.observe<MediatorEvent>(), throwsA(isA<MediatorAbstractObserveException>()));
    });
  });
}
