
Feature: Importing QIF files 
  In order to be able to use the information from my online bank
  A user of this program
  Should be able to import QIF files

  Scenario: Importing a QIF will create transactions
    Given I have no previous data
    When I import a QIF file
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
    Then the total number of transactions should be "4"
    And there is a transaction "TESCO STORE" of "-5.00" on "20/11/2009"
    And there is a transaction "EMPLOYER" of "5.00" on "21/11/2009"
    And there is a transaction "TESCO STORE" of "-5.00" on "22/11/2009"
    And there is a transaction "CAR PARK" of "-5.00" on "23/11/2009"
