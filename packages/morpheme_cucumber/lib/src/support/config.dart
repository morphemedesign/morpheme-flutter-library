import 'package:patrol/patrol.dart'
    show NativeAutomatorConfig, PatrolTesterConfig;

abstract class Config {
  Duration get timeout;
  PatrolTesterConfig get patrolTesterConfig;
  NativeAutomatorConfig get nativeAutomatorConfig;
  bool get skipScenario;
}
