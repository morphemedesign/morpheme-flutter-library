import 'package:collection/collection.dart';

import '../models/models.dart';
import 'reporter.dart';

class StdoutReporter extends Reporter {
  int passed = 0;
  int failed = 0;
  int skipped = 0;

  FeatureGherkinDocument? featureGherkinDocument;
  ChildrenFeatureGherkinDocument? childrenFeatureGherkinDocument;
  ChildrenFeatureGherkinDocument? childrenFeatureGherkinDocumentBackground;
  StepsGherkinDocument? stepsGherkinDocument;

  void printStdout(String message) {
    print('morpheme-cucumber-stdout: $message');
  }

  String? getIdScenario(ChildrenFeatureGherkinDocument? child) {
    if (child?.background != null) {
      return child?.background?.id;
    } else if (child?.scenario != null) {
      return child?.scenario?.id;
    } else if (child?.rule != null) {
      for (var element
          in child?.rule?.children ?? <ChildrenFeatureGherkinDocument>[]) {
        if (element.background != null) {
          return element.background?.id;
        } else if (element.scenario != null) {
          return element.scenario?.id;
        }
      }
    }
    return null;
  }

  StepsGherkinDocument? getStepsGherkinDocumentFromStepsPickle(
      ScenarioGherkinDocument? scenarioGherkinDocument,
      StepsPickle stepsPickle) {
    return scenarioGherkinDocument?.steps?.firstWhereOrNull(
        (stepsGherkinDocument) =>
            stepsPickle.astNodeIds?.firstWhereOrNull(
                (element) => element == stepsGherkinDocument.id) !=
            null);
  }

  @override
  Future<void> onGherkinLoaded(List<Gherkin> features) async {}
  @override
  Future<void> onDoneTest() async {
    printStdout('✅ passed: $passed, ❌ failed: $failed, ⭕ skipped: $skipped');
  }

  @override
  Future<void> onBeforeFeature(Gherkin feature) async {
    featureGherkinDocument = feature.gherkinDocument?.gherkinDocument?.feature;
    printStdout(
      '🚀 Feature ${feature.gherkinDocument?.gherkinDocument?.feature?.name ?? 'Unnamed'}',
    );
  }

  @override
  Future<void> onAfterFeature(Gherkin feature) async {
    featureGherkinDocument = null;
  }

  @override
  Future<void> onBeforeScenario(Gherkin feature, Pickle pickle) async {
    childrenFeatureGherkinDocument = featureGherkinDocument?.children
        ?.firstWhereOrNull((element) =>
            pickle.pickle?.astNodeIds?.firstWhereOrNull(
                (astNodeId) => getIdScenario(element) == astNodeId) !=
            null);

    childrenFeatureGherkinDocumentBackground = featureGherkinDocument?.children
        ?.firstWhereOrNull((element) => element.background != null);

    printStdout(
      '    📝 Scenario ${childrenFeatureGherkinDocument?.background?.name ?? childrenFeatureGherkinDocument?.scenario?.name ?? 'Unnamed'}',
    );
  }

  @override
  Future<void> onAfterScenario(Gherkin feature, Pickle pickle) async {
    childrenFeatureGherkinDocument = null;
    childrenFeatureGherkinDocumentBackground = null;
  }

  @override
  Future<void> onBeforeStep(
      Gherkin feature, Pickle pickle, StepsPickle step) async {
    if (childrenFeatureGherkinDocument?.background != null) {
      stepsGherkinDocument = getStepsGherkinDocumentFromStepsPickle(
          childrenFeatureGherkinDocument?.background, step);
    } else if (childrenFeatureGherkinDocument?.scenario != null) {
      stepsGherkinDocument = getStepsGherkinDocumentFromStepsPickle(
          childrenFeatureGherkinDocument?.scenario, step);
    } else if (childrenFeatureGherkinDocument?.rule != null) {
      for (var element in childrenFeatureGherkinDocument?.rule?.children ??
          <ChildrenFeatureGherkinDocument>[]) {
        if (element.background != null) {
          stepsGherkinDocument =
              getStepsGherkinDocumentFromStepsPickle(element.background, step);
        } else if (element.scenario != null) {
          stepsGherkinDocument =
              getStepsGherkinDocumentFromStepsPickle(element.scenario, step);
        }
      }
    }

    if (stepsGherkinDocument == null &&
        childrenFeatureGherkinDocumentBackground?.background != null) {
      stepsGherkinDocument = getStepsGherkinDocumentFromStepsPickle(
          childrenFeatureGherkinDocumentBackground?.background, step);
    }
  }

  @override
  Future<void> onFailedStep(Gherkin feature, Pickle pickle, StepsPickle step,
      int duration, Object exception) async {
    failed++;
    printStdout(
      '        ❌ Failed Step ${stepsGherkinDocument?.text ?? 'Unnamed'} in ${duration ~/ 1000000} milisecond',
    );
    printStdout('');
    printStdout(exception.toString());
    stepsGherkinDocument = null;
  }

  @override
  Future<void> onPassedStep(
      Gherkin feature, Pickle pickle, StepsPickle step, int duration) async {
    passed++;
    printStdout(
      '        ✅ Passed Step ${stepsGherkinDocument?.text ?? 'Unnamed'} in ${duration ~/ 1000000} milisecond',
    );
    stepsGherkinDocument = null;
  }

  @override
  Future<void> onSkipStep(
      Gherkin feature, Pickle pickle, StepsPickle step, int duration) async {
    skipped++;
    printStdout(
      '        ⭕ Skipped Step ${stepsGherkinDocument?.text ?? 'Unnamed'} in ${duration ~/ 1000000} milisecond',
    );
    stepsGherkinDocument = null;
  }
}
