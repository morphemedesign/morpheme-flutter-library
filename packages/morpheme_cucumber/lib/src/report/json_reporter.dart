import 'package:collection/collection.dart';
import 'package:morpheme_cucumber/src/report/reporter.dart';

import '../models/models.dart';
import 'json/json.dart';

class JsonReporter implements Reporter {
  List<JsonFeature> jsonFeatures = [];

  JsonFeature? jsonFeature;
  JsonScenario? jsonScenario;
  List<JsonScenario> jsonScenarios = [];
  JsonStep? jsonStep;
  List<JsonStep> jsonSteps = [];

  FeatureGherkinDocument? featureGherkinDocument;
  ChildrenFeatureGherkinDocument? childrenFeatureGherkinDocument;
  ChildrenFeatureGherkinDocument? childrenFeatureGherkinDocumentBackground;

  JsonFeature createJsonFeature(Gherkin gherkin) {
    final gherkinDocument = gherkin.gherkinDocument?.gherkinDocument;
    final feature = gherkin.gherkinDocument?.gherkinDocument?.feature;

    return JsonFeature(
      uri: gherkinDocument?.uri ?? '',
      name: feature?.name ?? '',
      description: feature?.description ?? '',
      line: feature?.location?.line ?? 0,
      id: feature?.name?.toLowerCase() ?? '',
      tags: feature?.tags
              ?.map((e) =>
                  JsonTag(name: e.name ?? '', line: e.location?.line ?? 0))
              .toList() ??
          [],
      elements: [],
      keyword: feature?.keyword ?? '',
    );
  }

  JsonScenario? createJsonScenario(ChildrenFeatureGherkinDocument scenario) {
    if (scenario.background != null || scenario.scenario != null) {
      final scenarioGherkinDocument = scenario.background ?? scenario.scenario;

      return JsonScenario(
        description: scenarioGherkinDocument?.description ?? '',
        id: scenarioGherkinDocument?.id ?? '',
        keyword: scenarioGherkinDocument?.keyword ?? '',
        line: scenarioGherkinDocument?.location?.line ?? 0,
        name: scenarioGherkinDocument?.name ?? '',
        type: scenarioGherkinDocument?.keyword?.toLowerCase() ?? '',
        tags: scenarioGherkinDocument?.tags
                ?.map((e) =>
                    JsonTag(name: e.name ?? '', line: e.location?.line ?? 0))
                .toList() ??
            [],
        steps: [],
      );
    }

    return null;
  }

  JsonStep createJsonStep(StepsGherkinDocument step) {
    return JsonStep(
      name: step.text ?? '',
      line: step.location?.line ?? 0,
      keyword: step.keyword ?? '',
      match: JsonMatch(
        location: 'integration_test/support/step_definitions.dart',
      ),
      result: JsonResult(
        status: JsonStatus.ambiguous,
        duration: 0,
      ),
    );
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

  void afterStep(JsonStatus status, int duration, [String? errorMessage]) {
    jsonStep = jsonStep?.copyWith(
      result: JsonResult(
        status: status,
        duration: duration,
        errorMessage: errorMessage,
      ),
    );
    if (jsonStep != null) jsonSteps.add(jsonStep!);
    jsonStep = null;
  }

  @override
  Future<void> onGherkinLoaded(List<Gherkin> features) async {}

  @override
  Future<void> onDoneTest() async {
    final cucumberReport =
        "cucumber-report: ${jsonFeatures.map((e) => e.toJson()).toList()}";
    print(cucumberReport.replaceAll(r'\"', r'\"'));
  }

  @override
  Future<void> onBeforeFeature(Gherkin feature) async {
    featureGherkinDocument = feature.gherkinDocument?.gherkinDocument?.feature;
    jsonFeature = createJsonFeature(feature);
  }

  @override
  Future<void> onAfterFeature(Gherkin feature) async {
    jsonFeature = jsonFeature?.copyWith(elements: [
      ...(jsonFeature?.elements ?? []),
      ...jsonScenarios,
    ]);
    if (jsonFeature != null) jsonFeatures.add(jsonFeature!);
    jsonFeature = null;
    featureGherkinDocument = null;
    jsonScenarios.clear();
  }

  @override
  Future<void> onBeforeScenario(Gherkin feature, Pickle picke) async {
    childrenFeatureGherkinDocument = featureGherkinDocument?.children
        ?.firstWhereOrNull((element) =>
            picke.pickle?.astNodeIds?.firstWhereOrNull(
                (astNodeId) => getIdScenario(element) == astNodeId) !=
            null);

    childrenFeatureGherkinDocumentBackground = featureGherkinDocument?.children
        ?.firstWhereOrNull((element) => element.background != null);

    if (childrenFeatureGherkinDocument != null) {
      jsonScenario = createJsonScenario(childrenFeatureGherkinDocument!);
    }
  }

  @override
  Future<void> onAfterScenario(Gherkin feature, Pickle picke) async {
    jsonScenario = jsonScenario?.copyWith(steps: [
      ...(jsonScenario?.steps ?? []),
      ...jsonSteps,
    ]);
    if (jsonScenario != null) jsonScenarios.add(jsonScenario!);
    jsonScenario = null;
    childrenFeatureGherkinDocument = null;
    childrenFeatureGherkinDocumentBackground = null;
    jsonSteps.clear();
  }

  @override
  Future<void> onBeforeStep(
      Gherkin feature, Pickle picke, StepsPickle step) async {
    StepsGherkinDocument? stepsGherkinDocument;
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

    if (stepsGherkinDocument != null) {
      jsonStep = createJsonStep(stepsGherkinDocument);
    }
  }

  @override
  Future<void> onFailedStep(Gherkin feature, Pickle picke, StepsPickle step,
      int duration, Object exception) async {
    afterStep(JsonStatus.failed, duration, exception.toString());
  }

  @override
  Future<void> onPassedStep(
      Gherkin feature, Pickle picke, StepsPickle step, int duration) async {
    afterStep(JsonStatus.passed, duration);
  }

  @override
  Future<void> onSkipStep(
      Gherkin feature, Pickle picke, StepsPickle step, int duration) async {
    afterStep(JsonStatus.skipped, duration);
  }
}
