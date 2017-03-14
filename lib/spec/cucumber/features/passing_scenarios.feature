Feature: Passing Scenarios
  As a tester
  I want to be able to test my code

  Background:
    Given I have tests setup

  Scenario: Run a passing test
    When I run the test
    Then I see the test pass

  Scenario: Run a passing test that takes a little while
    When I run a test that takes a while
    Then I see the test pass

