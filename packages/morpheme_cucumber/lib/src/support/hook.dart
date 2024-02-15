import 'package:patrol_finders/patrol_finders.dart';

class Hook {
  const Hook();

  Future<void> onBeforeExecute() async {}
  Future<void> onAfterExecute() async {}
  Future<void> onBeforeFeature(PatrolTester $) async {}
  Future<void> onAfterFeature(PatrolTester $) async {}
  Future<void> onBeforeScenario(PatrolTester $) async {}
  Future<void> onAfterScenario(PatrolTester $) async {}
  Future<void> onBeforeStep(PatrolTester $) async {}
  Future<void> onAfterStep(PatrolTester $) async {}
}
