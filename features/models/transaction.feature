
Feature: Transactions
  In order to perform calculations on their data
  A user of this program
  Should be able to store transactions in a database

  Scenario: Find the earliest transaction
    Given I have no previous data
    And I create a category called "Food"
    And I create a category called "Petrol"
    And I create a transaction of "Rice" on "20/10/2009" costing "50" in category "Food"
    And I create a transaction of "Diesel" on "21/10/2009" costing "100" in category "Petrol"
    When I find the earliest transaction
    Then the transaction with the name "Rice" costing "50" will be returned

