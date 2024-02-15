import 'package:core/core.dart';
import 'package:morpheme_cucumber/morpheme_cucumber.dart';

class CucumberConfig extends Config {
  @override
  bool get nativeAutomation => false;

  @override
  NativeAutomatorConfig get nativeAutomatorConfig =>
      const NativeAutomatorConfig(
        androidAppName: Environment.appName,
        iosAppName: Environment.appName,
        packageName: Environment.androidApplicationId,
        bundleId: Environment.iosApplicationId,
      );

  @override
  PatrolTesterConfig get patrolTesterConfig => const PatrolTesterConfig(
        visibleTimeout: Duration(minutes: 1),
      );

  @override
  bool get skipScenario => false;

  @override
  Duration get timeout => const Duration(minutes: 5);
}
