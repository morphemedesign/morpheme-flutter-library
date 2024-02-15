# Morpheme Cucumber

`morpheme_cucumber` package builds on top of `patrol` and `integration_test` to make
it easy to integration test with gherkin language.

It can be used on [morpheme_cli](https://pub.dev/packages/morpheme_cli).

## Installation

installation morpheme_cli

```console
dart pub global activate morpheme_cli
```

installation morpheme flutter in your project

```console
morpheme create
```

### Morpheme Cli

Now you done for setup all MorphemeCucumber then you can call morpheme command:

First init to create morpheme.yaml

```console
morpheme init
```

Then download all dependency with morpheme get

```console
morpheme get
```

Last you can run cucumber command

```console
morpheme cucumber
```

by default run `integration_test/cucumber_test.dart` by flavor dev. if you want to running flavor stag or prod just add argument `--flavor stag` or `--flavor prod`

## Usage

To use morpheme_cucumber create file `cucumber_test.dart` in your `integration_test` directory.
Then import it:

```dart
import 'package:morpheme_cucumber/morpheme_cucumber.dart';
```

Once imported, you can write widget tests:

```dart title="integration_test/cucumber_test.dart"
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
```

### Config

You can create `Config` or make it default null:

```dart title="integration_test/support/cucumber_config.dart"
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
```

### Hook

Now you can add your `Hook` for cucumber:

```dart title="integration_test/support/cucumber_hook.dart"
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
```

### Step Definitions

and the requirement morpheme_cucumber its `step_definitions.dart`:

```dart title="integration_test/support/step_definitions.dart"
import 'package:flutter/material.dart';
import 'package:morpheme_cucumber/morpheme_cucumber.dart';

Map<RegExp, Function> stepDefinitions = {
  // Action
  RegExp(r'I wait for "([^"]*)" key to visible'):
      (PatrolTester $, String key) async {
    await $(Key(key)).waitUntilVisible();
  },
  RegExp(r'I clear textfield in "([^"]*)" key'):
      (PatrolTester $, String key) async {
    await $(Key(key)).enterText('');
  },
  RegExp(r'I enter "([^"]*)" into "([^"]*)" key'):
      (PatrolTester $, String value, String key) async {
    await $(Key(key)).enterText(value);
  },
  RegExp(r'I scroll in "([^"]*)" key until visible "([^"]*)" key'):
      (PatrolTester $, String scrollKey, String visibleKey) async {
    await $(Key(visibleKey))
        .scrollTo(scrollable: $(Key(scrollKey)).$(Scrollable));
  },
  RegExp(r'I tap "([^"]*)" key'): (PatrolTester $, String key) async {
    await $(Key(key)).tap();
  },
  RegExp(r'I longtap "([^"]*)" key'): (PatrolTester $, String key) async {
    await $.tester.longPress($(key));
  },
};
```

you can add your custom another step definitions with `RegExp`

- String `"([^"]*)"`
- num `"(\d+)"`
- Select `"(JSON|YAML|XML|HTML)"`

or other reg exp just on grouping `()`.

### Add Assets in pubspec.yaml

1. Create directory in `integration_test/ndjson/`
2. Then add as assets in `pubspec.yaml`

```yaml title="pubspec.yaml"
...
flutter:
  uses-material-design: true
  assets:
    - integration_test/ndjson/
```

### Reporters

Reporters are classes that are able to report on the status of the test run. This could be a simple as merely logging scenario result to the console. There are a number of built-in reporter:

- `StdoutReporter` : Logs all messages from the test run to the standard output (console).
- `JsonReporter` : creates a JSON file with the results of the test run which can then be used by '<https://www.npmjs.com/package/cucumber-html-reporter>.' to create a HTML report. You can pass in the file path of the json file to be created

### Features

write your feature in integration_test/features/login.feature:

```feature title="integration_test/features/login.feature"
Feature: Login

  Scenario: Login with username and pin then failed
    When I enter "example@morpheme.id" into "inputEmail" key
    When I scroll in "scrollLogin" key until visible "inputPin" key
    When I enter "123455" into "inputPin" key
    When I scroll in "scrollLogin" key until visible "btnLogin" key
    When I tap "btnLogin" key

  Scenario: Login with username and pin then success
    When I enter "example@morpheme.id" into "inputEmail" key
    When I scroll in "scrollLogin" key until visible "inputPin" key
    When I enter "123456" into "inputPin" key
    When I scroll in "scrollLogin" key until visible "btnLogin" key
    When I tap "btnLogin" key
```
