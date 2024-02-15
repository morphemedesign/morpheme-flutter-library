var reporter = require("cucumber-html-reporter");

const projectName = "Morpheme Cucumber";
const appVersion = "1.0.0";
const environment = "Staging";

/* This is the configuration for the report. */
var options = {
  name: projectName,
  brandTitle: projectName + "Test Report",
  theme: "bootstrap",
  jsonFile: "cucumber-report.json",
  output: "cucumber-report.html",
  reportSuiteAsScenarios: true,
  scenarioTimestamp: true,
  launchReport: true,
  metadata: {
    "App Version": appVersion,
    Environment: environment,
  },
};

/* Generating a HTML report based on the cucumber JSON file. */
reporter.generate(options);

//more info on `metadata` is available in `options` section below.

//to generate consodilated report from multi-cucumber JSON files, please use `jsonDir` option instead of `jsonFile`. More info is available in `options` section below.
