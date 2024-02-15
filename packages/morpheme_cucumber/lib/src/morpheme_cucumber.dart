import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morpheme_cucumber/src/report/reporter.dart';
import 'package:morpheme_cucumber/src/support/support.dart';
import 'package:patrol_finders/patrol_finders.dart';

import 'models/models.dart';

class MorphemeCucumber {
  MorphemeCucumber({
    this.config,
    this.hook = const Hook(),
    this.reporter = const [],
    required this.stepDefinitions,
  });

  final Config? config;
  final Hook hook;
  final List<Reporter> reporter;
  final Map<RegExp, Function> stepDefinitions;

  List<Gherkin> gherkins = [];

  Future<List<Gherkin>> _getGherkinFromNdjson() async {
    final ndjsonGherkin = await rootBundle
        .loadString('integration_test/ndjson/ndjson_gherkin.json');

    if (ndjsonGherkin.isEmpty) {
      print(
          'integration_test/ndjson/ndjson_gherkin.json is empty please set assets this in your pubspec.yaml');
      exit(1);
    }

    List<Gherkin> gherkins = [];

    final List jsonGherkin = jsonDecode(ndjsonGherkin);

    for (final element in jsonGherkin) {
      Source? source;
      GherkinDocument? gherkinDocument;
      List<Pickle> pickles = [];

      final jsons = element['ndjson'].split('\n');
      for (int i = 0; i < jsons.length; i++) {
        final json = jsons[i];
        switch (i) {
          case 0:
            source = Source.fromJson(json);
            break;
          case 1:
            gherkinDocument = GherkinDocument.fromJson(json);
            break;
          default:
            pickles.add(Pickle.fromJson(json));
        }
      }

      gherkins.add(Gherkin(
        source: source,
        gherkinDocument: gherkinDocument,
        pickles: pickles,
      ));
    }

    return gherkins;
  }

  Future<void> execute() async {
    gherkins = await _getGherkinFromNdjson();
    await reporter.onGherkinLoaded(gherkins);
    await hook.onBeforeExecute();
    for (final feature in gherkins) {
      await _handleFeature(feature);
    }
  }

  Future<void> _handleFeature(Gherkin feature) async {
    group(feature.gherkinDocument?.gherkinDocument?.feature?.name ?? '', () {
      for (final scenario in feature.pickles) {
        patrolWidgetTest(
          scenario.pickle?.name ?? '',
          ($) async {
            if (feature.pickles.first == scenario) {
              await reporter.onBeforeFeature(feature);
              await hook.onBeforeFeature($);
            }

            await _handleScenario(feature, scenario, $);

            if (feature.pickles.last == scenario) {
              await hook.onAfterFeature($);
              await reporter.onAfterFeature(feature);
            }

            if (gherkins.last == feature && feature.pickles.last == scenario) {
              await hook.onAfterExecute();
              await reporter.onDoneTest();
            }
          },
          timeout: Timeout(config?.timeout),
          config: config?.patrolTesterConfig ?? PatrolTesterConfig(),
          skip: config?.skipScenario,
        );
      }
    });
  }

  Future<void> _handleScenario(
      Gherkin feature, Pickle scenario, PatrolTester $) async {
    bool skipAnotherStep = false;
    await reporter.onBeforeScenario(feature, scenario);
    await hook.onBeforeScenario($);
    for (final step in scenario.pickle?.steps ?? <StepsPickle>[]) {
      DateTime now = DateTime.now();
      await reporter.onBeforeStep(feature, scenario, step);
      if (skipAnotherStep) {
        await reporter.onSkipStep(feature, scenario, step, 0);
        continue;
      }
      try {
        bool foundRegExp = false;
        for (final regExp in stepDefinitions.keys) {
          if (regExp.hasMatch(step.text ?? '')) {
            foundRegExp = true;
            await _handleStep($, regExp, feature, scenario, step);
            final duration = (DateTime.now().millisecondsSinceEpoch -
                    now.millisecondsSinceEpoch) *
                1000000;
            await reporter.onPassedStep(feature, scenario, step, duration);
            break;
          }
        }

        if (!foundRegExp) {
          throw Exception('${step.text} is not define in step definitions');
        }
      } catch (e) {
        final duration = (DateTime.now().millisecondsSinceEpoch -
                now.millisecondsSinceEpoch) *
            1000000;
        await reporter.onFailedStep(feature, scenario, step, duration, e);
        skipAnotherStep = true;
      }
    }
    await hook.onAfterScenario($);
    await reporter.onAfterScenario(feature, scenario);
  }

  Future<void> _handleStep(PatrolTester $, RegExp regExp, Gherkin feature,
      Pickle scenario, StepsPickle step) async {
    await hook.onBeforeStep($);

    final match = regExp.firstMatch(step.text ?? '');
    final count = match?.groupCount;
    switch (count ?? 0) {
      case 0:
        await stepDefinitions[regExp]?.call($);
        break;
      case 1:
        await stepDefinitions[regExp]?.call($, match?.group(1));
        break;
      case 2:
        await stepDefinitions[regExp]
            ?.call($, match?.group(1), match?.group(2));
        break;
      case 3:
        await stepDefinitions[regExp]
            ?.call($, match?.group(1), match?.group(2), match?.group(3));
        break;
      case 4:
        await stepDefinitions[regExp]?.call($, match?.group(1), match?.group(2),
            match?.group(3), match?.group(4));
        break;
      case 5:
        await stepDefinitions[regExp]?.call($, match?.group(1), match?.group(2),
            match?.group(3), match?.group(4), match?.group(5));
        break;
      case 6:
        await stepDefinitions[regExp]?.call($, match?.group(1), match?.group(2),
            match?.group(3), match?.group(4), match?.group(5), match?.group(6));
        break;
      case 7:
        await stepDefinitions[regExp]?.call(
            $,
            match?.group(1),
            match?.group(2),
            match?.group(3),
            match?.group(4),
            match?.group(5),
            match?.group(6),
            match?.group(7));
        break;
      case 8:
        await stepDefinitions[regExp]?.call(
            $,
            match?.group(1),
            match?.group(2),
            match?.group(3),
            match?.group(4),
            match?.group(5),
            match?.group(6),
            match?.group(7),
            match?.group(8));
        break;
      case 9:
        await stepDefinitions[regExp]?.call(
            $,
            match?.group(1),
            match?.group(2),
            match?.group(3),
            match?.group(4),
            match?.group(5),
            match?.group(6),
            match?.group(7),
            match?.group(8),
            match?.group(9));
        break;
      default:
        throw Exception('Maximum argument is 9 in step definitions');
    }

    await hook.onAfterStep($);
  }
}
