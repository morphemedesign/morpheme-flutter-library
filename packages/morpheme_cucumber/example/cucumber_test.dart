import 'package:morpheme_cucumber/morpheme_cucumber.dart';

import 'support/cucumber_config.dart';
import 'support/cucumber_hook.dart';
import 'support/step_definitions.dart';

void main() async {
  await MorphemeCucumber(
    config: CucumberConfig(),
    hook: CucumberHook(),
    reporter: [JsonReporter(), StdoutReporter()],
    stepDefinitions: stepDefinitions,
  ).execute();
}
