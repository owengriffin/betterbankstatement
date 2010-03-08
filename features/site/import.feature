Feature: BetterBankStatement import
  In order for users to gather statistics
  As a user I must be able to import my bank statements

  Scenario: Import a QIF file
    Given I have no previous data
    When I visit the "Import" page
    And I click on the "QIF" link
    Then I should see the text "QIF"
    And I upload a file to "import_file" with the content
    """
    !Type:Oth L
    D20/11/2009
    T-5.00
    PTESCO STORE
    ^
    D21/11/2009
    T5.00
    PEMPLOYER
    ^
    D22/11/2009
    T-5.00
    PTESCO STORE
    ^
    D23/11/2009
    T-5.00
    PCAR PARK
    ^
    """
    And I hit the "Import" button
    Then I should see the text "4 transactions imported. 0 duplicates"
    When I visit the "Transactions" page
    Then I should see the text "2009/11"
    When I click on the "2009/11" link
    Then I should see the text "TESCO STORE"
    And I should see the text "EMPLOYER"
    And I should see the text "TESCO STORE"
    And I should see the text "CAR PARK"

  Scenario: Import a text file
    When I have no previous data
    When I visit the "Import" page
    And I click on the "PDF" link
    Then I should see the text "You will need to convert the PDF file to text using pdf2text before uploading it."
    And I upload a file to "import_file" with the content
    """
    Your Transaction Details
    Received By Us   Transaction Date   Details                                                                       Amount

     20 Nov 09        20 Nov 09          TESCO STORE                                                                    5.00
     21 Nov 09        21 Nov 09          EMPLOYER                                                                     5.00CR
     22 Nov 09        22 Nov 09          TESCO STORE                                                                    5.00
     23 Nov 09        23 Nov 09          CAR PARK                                                                       5.00
    """
    And I hit the "Import" button
    Then I should see the text "4 transactions imported. 0 duplicates"
    Then I should see the text "2009/11"
    When I click on the "2009/11" link
    Then I should see the text "TESCO STORE"
    And I should see the text "EMPLOYER"
    And I should see the text "TESCO STORE"
    And I should see the text "CAR PARK"


  Scenario: Exclude duplicate transactions
    Given I have no previous data
    When I visit the "Import" page
    And I click on the "QIF" link
    And I upload a file to "import_file" with the content
    """
    !Type:Oth L
    D20/11/2009
    T-5.00
    PTESCO STORE
    ^
    D21/11/2009
    T5.00
    PEMPLOYER
    ^
    D22/11/2009
    T-5.00
    PTESCO STORE
    ^
    D23/11/2009
    T-5.00
    PCAR PARK
    ^
    """
    And I hit the "Import" button
    Then I should see the text "4 transactions imported. 0 duplicates."
    When I visit the "Import" page
    And I click on the "QIF" link
    And I upload a file to "import_file" with the content
    """
    !Type:Oth L
    D20/11/2009
    T-5.00
    PTESCO STORE
    ^
    D21/11/2009
    T5.00
    PEMPLOYER
    ^
    D22/11/2009
    T-5.00
    PTESCO STORE
    ^
    D23/11/2009
    T-5.00
    PCAR PARK
    ^
    """
    And I hit the "Import" button
    Then I should see the text "0 transactions imported. 4 duplicates."
