Feature: Scenarios that have not been implemented


Scenario: Run a test that isnt implemented
  Given I have a given step that is not implemented
  When I try to run a test
  Then I see that it doesnt run

Scenario: Run a test that has pending steps
  Given I have a pending step
  When I try to run the test
  Then I see that it didnt run