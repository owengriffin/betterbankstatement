
Feature: Filtering of transactions on import
  In order to be able to see how much I have spent on different things
  A user of this program
  Should be able to categorize transactions based on their description

  Scenario: Basic filtering
    Given I have no previous data
    And I create a category called "Food"
    And I create a filter matching "TESCO|ASDA" for category "Food"
    And I create a transaction of "TESCO SOMEWHERE" on "21/10/2009" costing "10"
    When I filter the transactions
    Then the category "Food" will contain the transaction "TESCO SOMEWHERE" costing "10"

  Scenario: Import filters
    Given I have no previous data
    And I import the filter file "filters.yaml"
    And I create a transaction of "TESCO STORE SOMEWHERE" on "21/10/2009" costing "10"
    When I filter the transactions
    Then the category "Food" will contain the transaction "TESCO STORE SOMEWHERE" costing "10"
