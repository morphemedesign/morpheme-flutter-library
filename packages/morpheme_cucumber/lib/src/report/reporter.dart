import '../models/models.dart';

extension ListReporters on List<Reporter> {
  Future<void> onGherkinLoaded(List<Gherkin> feature) async {
    for (var element in this) {
      await element.onGherkinLoaded(feature);
    }
  }

  Future<void> onDoneTest() async {
    for (var element in this) {
      await element.onDoneTest();
    }
  }

  Future<void> onBeforeFeature(Gherkin feature) async {
    for (var element in this) {
      await element.onBeforeFeature(feature);
    }
  }

  Future<void> onAfterFeature(Gherkin feature) async {
    for (var element in this) {
      await element.onAfterFeature(feature);
    }
  }

  Future<void> onBeforeScenario(Gherkin feature, Pickle scenario) async {
    for (var element in this) {
      await element.onBeforeScenario(feature, scenario);
    }
  }

  Future<void> onAfterScenario(Gherkin feature, Pickle scenario) async {
    for (var element in this) {
      await element.onAfterScenario(feature, scenario);
    }
  }

  Future<void> onBeforeStep(
      Gherkin feature, Pickle scenario, StepsPickle step) async {
    for (var element in this) {
      await element.onBeforeStep(feature, scenario, step);
    }
  }

  Future<void> onPassedStep(
      Gherkin feature, Pickle scenario, StepsPickle step, int duration) async {
    for (var element in this) {
      await element.onPassedStep(feature, scenario, step, duration);
    }
  }

  Future<void> onFailedStep(Gherkin feature, Pickle pickle, StepsPickle step,
      int duration, Object exception) async {
    for (var element in this) {
      await element.onFailedStep(feature, pickle, step, duration, exception);
    }
  }

  Future<void> onSkipStep(
      Gherkin feature, Pickle pickle, StepsPickle step, int duration) async {
    for (var element in this) {
      await element.onSkipStep(feature, pickle, step, duration);
    }
  }
}

abstract class Reporter {
  Future<void> onGherkinLoaded(List<Gherkin> features);
  Future<void> onDoneTest();
  Future<void> onBeforeFeature(Gherkin feature);
  Future<void> onAfterFeature(Gherkin feature);
  Future<void> onBeforeScenario(Gherkin feature, Pickle pickle);
  Future<void> onAfterScenario(Gherkin feature, Pickle pickle);
  Future<void> onBeforeStep(Gherkin feature, Pickle pickle, StepsPickle step);
  Future<void> onFailedStep(Gherkin feature, Pickle pickle, StepsPickle step,
      int duration, Object exception);
  Future<void> onPassedStep(
    Gherkin feature,
    Pickle pickle,
    StepsPickle step,
    int duration,
  );
  Future<void> onSkipStep(
    Gherkin feature,
    Pickle pickle,
    StepsPickle step,
    int duration,
  );
}
