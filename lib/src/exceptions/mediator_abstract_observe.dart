import 'package:dmediator/src/abstract/mediator_event.dart';

class MediatorAbstractObserveException implements Exception {
  @override
  String toString() {
    return "$runtimeType: Attempt to observe abstract <$MediatorEvent> class";
  }
}