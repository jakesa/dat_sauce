Feature: Passing Scenario Outlines

  Scenario Outline: Passing Scenario Outline
    Given I have my outline setup
    When I run test with name <name>
    Then I see the test pass

    Examples:
      | name  |
      | this  |
      | that  |
      | other |