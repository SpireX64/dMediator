import 'package:dmediator/dmediator_abstract.dart';
import 'package:mocktail/mocktail.dart';

class FakeMessage extends Fake implements MediatorMessage<String> {}
class AnotherFakeMessage extends Fake implements MediatorMessage<int> {}

class MockMediatorHandler<R, TMessage extends MediatorMessage<R>> extends Mock implements MediatorHandler<R, TMessage> {}