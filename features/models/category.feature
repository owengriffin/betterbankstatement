
Feature: Categorization of transactions
  In order to be able to see how much I have spent on different things
  A user of this program
  Should be able to categorize transactions based on their description

  Scenario: Creating categories
    Given I have no previous data
    And I create a category called "Food"
    When I get the category called "Food"
    Then the category "Food" will be returned

  Scenario: Listing categories
    Given I have no previous data
    And I create a category called "Food"
    When I list all categories
    Then a list with the category "Food" will be returned

  Scenario: Calculate the cumulative total for all transactions in a category
    Given I have no previous data
    And I create a category called "Food"
    And I create a transaction of "Rice" on "21/10/2009" costing "10" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "30" in category "Food"
    When I calculate the total all transactions in the "Food" category
    Then "40" will be returned

  Scenario: Calculate the cumulative total for transactions in a category between a range of dates
    Given I have no previous data
    And I create a category called "Food"
    And I create a transaction of "Rice" on "20/10/2009" costing "10" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "20" in category "Food"
    And I create a transaction of "Bread" on "22/10/2009" costing "30" in category "Food"
    And I create a transaction of "Fish" on "23/10/2009" costing "40" in category "Food"
    When I calculate the total of all transactions between "20/10/2009" and "22/10/2009" in the "Food" category
    Then "60" will be returned
    When I calculate the total of all transactions between "20/10/2009" and "21/10/2009" in the "Food" category
    Then "30" will be returned
    When I calculate the total of all transactions between "20/10/2009" and "20/10/2009" in the "Food" category
    Then "10" will be returned
    When I calculate the total of all transactions between "20/10/2009" and "23/10/2009" in the "Food" category
    Then "100" will be returned

  Scenario: Calculate the total amount debited for all transactions in a category
    Given I have no previous data
    And I create a category called "Food"
    And I create a transaction of "Rice" on "21/10/2009" costing "-10" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "30" in category "Food"
    When I calculate the debit of all transactions of category "Food"
    Then "-10" will be returned   

  Scenario: Calculate the total amount debited for transactions in a category between a range of dates
    Given I have no previous data
    And I create a category called "Food"
    And I create a transaction of "Rice" on "20/10/2009" costing "-10" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "-20" in category "Food"
    And I create a transaction of "Bread" on "22/10/2009" costing "-30" in category "Food"
    And I create a transaction of "Fish" on "23/10/2009" costing "-40" in category "Food"
    When I calculate the total amount debited of all transactions between "20/10/2009" and "22/10/2009" in the "Food" category
    Then "-60" will be returned
    When I calculate the total amount debited of all transactions between "20/10/2009" and "21/10/2009" in the "Food" category
    Then "-30" will be returned
    When I calculate the total amount debited of all transactions between "20/10/2009" and "20/10/2009" in the "Food" category
    Then "-10" will be returned
    When I calculate the total amount debited of all transactions between "20/10/2009" and "23/10/2009" in the "Food" category
    Then "-100" will be returned   

  Scenario: Calculate the total amount credited for all transactions in a category
    Given I have no previous data
    And I create a category called "Food"
    And I create a transaction of "Rice" on "21/10/2009" costing "-10" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "30" in category "Food"
    When I calculate the credit of all transactions of category "Food"
    Then "30" will be returned   
 
  Scenario: Calculate the total amount credited for transactions in a category between a range of dates
    Given I have no previous data
    And I create a category called "Food"
    And I create a transaction of "Rice" on "20/10/2009" costing "10" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "20" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "-20" in category "Food"
    And I create a transaction of "Bread" on "22/10/2009" costing "30" in category "Food"
    And I create a transaction of "Bread" on "22/10/2009" costing "-30" in category "Food"
    And I create a transaction of "Fish" on "23/10/2009" costing "40" in category "Food"
    When I calculate the total amount credited of all transactions between "20/10/2009" and "22/10/2009" in the "Food" category
    Then "60" will be returned
    When I calculate the total amount credited of all transactions between "20/10/2009" and "21/10/2009" in the "Food" category
    Then "30" will be returned
    When I calculate the total amount credited of all transactions between "20/10/2009" and "20/10/2009" in the "Food" category
    Then "10" will be returned
    When I calculate the total amount credited of all transactions between "20/10/2009" and "23/10/2009" in the "Food" category
    Then "100" will be returned

  Scenario: Calculate the average amount spent in a category
    Given I have no previous data
    And I create a category called "Food"
    And I create a transaction of "Rice" on "20/10/2009" costing "10" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "-20" in category "Food"
    And I create a transaction of "Bread" on "22/10/2009" costing "-30" in category "Food"
    And I create a transaction of "Fish" on "23/10/2009" costing "100" in category "Food"
    When I calculate the average amount spent on a transaction in the "Food" category
    Then "15.0" will be returned

  Scenario: Calculate the average amount spent in a category between a range of dates
    Given I have no previous data
    And I create a category called "Food"
    And I create a transaction of "Rice" on "20/10/2009" costing "10" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "-20" in category "Food"
    And I create a transaction of "Bread" on "22/10/2009" costing "-30" in category "Food"
    And I create a transaction of "Fish" on "23/10/2009" costing "100" in category "Food"
    When I calculate the average amount spent on a transactions between "20/10/2009" and "21/10/2009" in the "Food" category
    Then "-5.0" will be returned
    When I calculate the average amount spent on a transactions between "22/10/2009" and "23/10/2009" in the "Food" category
    Then "35.0" will be returned

  Scenario: Find the earliest transaction in the category
    Given I have no previous data
    And I create a category called "Food"
    And I create a transaction of "Rice" on "20/10/2009" costing "50" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "100" in category "Food"
    When I find the earliest transaction in the category "Food"
    Then the transaction with the name "Rice" costing "50" will be returned

  Scenario: Calculate the monthly average spend in a category
    Given I have no previous data
    And I create a category called "Food"
    And I create a transaction of "Rice" on "20/10/2009" costing "50" in category "Food"
    And I create a transaction of "Smarties" on "21/10/2009" costing "100" in category "Food"
    And I create a transaction of "Bread" on "20/11/2009" costing "30" in category "Food"
    And I create a transaction of "Fish" on "21/11/2009" costing "30" in category "Food"
    And I create a transaction of "Bread" on "20/12/2009" costing "-50" in category "Food"
    And I create a transaction of "Fish" on "21/12/2009" costing "50" in category "Food"
    And I create a transaction of "Bread" on "20/01/2010" costing "-50" in category "Food"
    And I create a transaction of "Fish" on "21/01/2010" costing "50" in category "Food"
    And I create a transaction of "Bread" on "today" costing "-1000" in category "Food"
    And I create a transaction of "Fish" on "today" costing "50" in category "Food"
    When I calculate the monthly average spent on the "Food" category
    Then "21.0" will be returned
