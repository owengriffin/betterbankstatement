
Feature: Importing PDF files 
  In order to be able to use the information from my online bank
  A user of this program
  Should be able to import PDF files

  Scenario: Importing a converted PDF document
    Given I have no previous data
    When I import a PDF file
    """
    Your Transaction Details
    Received By Us   Transaction Date   Details                                                                       Amount

     20 Nov 09        20 Nov 09          TESCO STORE                                                                    5.00
     21 Nov 09        21 Nov 09          EMPLOYER                                                                     5.00CR
     22 Nov 09        22 Nov 09          TESCO STORE                                                                    5.00
     23 Nov 09        23 Nov 09          CAR PARK                                                                       5.00
    """
    Then the total number of transactions should be "4"
    And there is a transaction "TESCO STORE" of "-5.00" on "20/11/2009"
    And there is a transaction "EMPLOYER" of "5.00" on "21/11/2009"
    And there is a transaction "TESCO STORE" of "-5.00" on "22/11/2009"
    And there is a transaction "CAR PARK" of "-5.00" on "23/11/2009"
