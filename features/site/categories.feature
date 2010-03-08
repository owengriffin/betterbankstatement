
Feature: BetterBankStatement website
  In order to view my bank statements
  A user of this program
  Should be able to view them as a web page

  Scenario: Adding a new category
    Given I have no previous data
    When I visit the "Categories" page
    Then I should not see a list of categories
    When I click on the "Categories" link
    Then I should see the text "There are no categories."
    When I click on the "New Category" link
    Then I should see the text "Name:"
    Then I fill in "name" with "An obscure category name"
    When I hit the "Create" button
    Then I should see the text "Category 'An obscure category name' created successfully"
    And I should see a list of categories
    And I should see the text "An obscure category name"

  Scenario: Viewing a list of categories
    Given I have no previous data
    Given I create a category called "Food"
    Given I create a category called "Petrol"
    When I visit the "Categories" page
    Then I should see a list of categories
    And I should see the text "Food"
    And I should see the text "Petrol"
    
  Scenario: Viewing detail of a particular category
    Given I have no previous data
    Given I create a category called "Food"
    Given I create a category called "Petrol"
    When I visit the "Categories" page
    When I click on the "Food" link
    Then I am on the "/category/Food" page
