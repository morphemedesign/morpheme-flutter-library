import 'package:core/core.dart';
import 'package:morpheme_cucumber/morpheme_cucumber.dart';
import 'package:morpheme_flutter_starter_kit/main.dart' as app;

class CucumberHook extends Hook {
  @override
  Future<void> onBeforeExecute() async {
    await app.init();
  }

  @override
  Future<void> onAfterExecute() async {}

  @override
  Future<void> onBeforeFeature(PatrolTester $) async {}

  @override
  Future<void> onAfterFeature(PatrolTester $) async {
    await FlutterSecureStorageHelper.logout();
  }

  @override
  Future<void> onBeforeScenario(PatrolTester $) async {
    await $.pumpWidget(const app.MyApp());
  }

  @override
  Future<void> onAfterScenario(PatrolTester $) async {
    locator<GoRouter>().go('/');
  }

  @override
  Future<void> onBeforeStep(PatrolTester $) async {}

  @override
  Future<void> onAfterStep(PatrolTester $) async {}
}
