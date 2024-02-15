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
