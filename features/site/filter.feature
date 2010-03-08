Feature: Filtering transactions
  In order transactions to be automatically categorised
  As a user I should be able to filter my transactions

  Scenario: Create a new filter
    Given I have no previous data
    When I visit the "Filters" page
    Then I should see the text "There are currently no filters."
    When I click on the "New Filter" link
    Then I should see the text "Transaction containing:"
    Then I fill in "expression" with "TESCO"
    Then I fill in "category" with "Food"
    When I hit the "Create" button
    Then I should see the text "Filter created successfully"
    And I should see a list of filters
    And I should see the text "TESCO -> Food"

  Scenario: Export filters
    Given I have no previous data
    And I create the filter matching "TESCO" for the category "Food"
    And I create the filter matching "SHELL" for the category "Car"
    When I visit the "Filters" page
    Then I should see the text "TESCO -> Food"
    Then I should see the text "SHELL -> Car"
    When I click on the "Export Filters" link
    Then I should receive the content "[{"expression":"TESCO","category_name":"Food"},{"expression":"SHELL","category_name":"Car"}]"

  Scenario: Import filters
    Given I have no previous data
    When I visit the "Filters" page
    Then I should see the text "There are currently no filters."
    When I click on the "Import Filters" link
    Then I should see the text "File:"
    And I upload the filter file with the content
    """
    [{"expression":"TESCO","category_name":"Food"},{"expression":"SHELL","category_name":"Car"}]
    """
    And I hit the "Import" button
    Then I should see the text "2 filters imported"
    When I visit the "Filters" page
    Then I should see the text "TESCO -> Food"
    Then I should see the text "SHELL -> Car" 

  Scenario: Delete filters
    Given I have no previous data
    And I create the filter matching "TESCO" for the category "Food"
    And I create the filter matching "SHELL" for the category "Car"
    When I visit the "Filters" page
    Then I should see the text "TESCO -> Food"
    Then I should see the text "SHELL -> Car"
    When I click on the "Delete TESCO -> Food filter" link
    Then I should see the text "Are you sure you want to delete the filter TESCO -> Food?"
    Then I should select "confirm"
    When I hit the "Delete" button
    Then I should see the text "Filter deleted"
    When I visit the "Filters" page
    Then I should see the text "SHELL -> Car"
    And I should not see the text "TESCO -> Food"

  Scenario: Apply filters on transactions
    Given I have no previous data
    And I create the filter matching "TESCO" for the category "Food"
    And I create the filter matching "SHELL" for the category "Car"
    And I create a transaction of "TESCO TR1" on "21/10/2009" costing "10"
    And I create a transaction of "TESCO TR2" on "21/10/2009" costing "30"
    And I create a transaction of "SHELL" on "22/10/2009" costing "10"
    And I create a transaction of "TESCO TR3" on "22/10/2009" costing "30"
    When I visit the "Filters" page
    Then I should see the text "TESCO -> Food"
    Then I should see the text "SHELL -> Car"
    When I click on the "Apply Filters" link
    Then I should see the text "Filters applied"
    When I visit the "Categories" page
    And I click on the "Food" link
    Then I should see the text "TESCO TR1 10"
    Then I should see the text "TESCO TR2 30"
    Then I should see the text "TESCO TR3 30"


    
    
