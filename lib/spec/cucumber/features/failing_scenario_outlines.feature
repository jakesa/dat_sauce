Feature: Failing Scenario Outline

  Scenario Outline: Failing Scenario Outline
    Given I have my outline setup
    When I run test with name <name>
    Then I see the test fail

    Examples:
      | name  |
      | this  |
      | that  |
      | other |