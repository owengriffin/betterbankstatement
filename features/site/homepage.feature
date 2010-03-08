Feature: BetterBankStatement Homepage
  In order to make users happy

  Scenario: Homepage
    Given I have no previous data
    When I visit the "Home" page
    Then I should see the text "BetterBankStatement"
