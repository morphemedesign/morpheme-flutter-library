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
