Feature: Failing Scenarios

Scenario: Run a failing test
Given I have tests setup
When I run the test
Then I see the test fail

Scenario: Run a failing test that take a little while
Given I have tests setup
When I run a test that takes a while
Then I see the test fail