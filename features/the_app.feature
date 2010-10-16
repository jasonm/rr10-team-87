Feature: The whole app

  Scenario: New user gets desperate
    When I go to the home page
    And I fill in "8004688487" as my phone number
    And I press the sign up button
    Then I get a text with my secret code
    When I fill in my secret code
    And I fill in the date of birth with "December 31, 1977"
    And I fill in my name as "Mike"
    And I fill in my description as "black shirt, glasses, math book"
    And I check my gender as male
    And I fill in the minimum age with "21"
    And I fill in the maximum age with "34"
    And I check my desired gender as female
    And I submit my profile
    Then I see a description of how to use the Web site
    And "8004688487" is confirmed

  @wip
  Scenario: Existing user tries to get some and is happy with everything
    Given the following users exist:
      | Phone Number | Male | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Description |
      | 1111111111   | yes  | no     | no               | yes                | 11-06-1983   | 18                      | 34                      | red hair    |
      | 2222222222   | no   | yes    | yes              | no                 | 10-20-1983   | 18                      | 34                      | black shirt |
      | 8004688487   | yes  | yes    | yes              | yes                | 12-31-1977   | 14                      | 22                      | super hot   |
    When "8004688487" texts instalover with "new date"
    Then "8004688487" gets a response of "Silvertone" at "9:00"

    When "8004688487" text instalover with "ok"
    Then "1111111111" should get a text "Want to go on a date at Silvertone at 9:00?  Reply 'ok' or ignore."
    And  "2222222222" should get a text "Want to go on a date at Silvertone at 9:00?  Reply 'ok' or ignore."

    When "1111111111" texts instalover with "ok"
    Then "2222222222" should get a text "Too slow!  Would you like to get a date?  Reply 'new date'."
    And "1111111111" should get a text "You got it!  Meet at Silvertone at 9:00.  Your date is: 'super hot'"
    And "8004688487" should get a text "You got it!  Meet at Silvertone at 9:00.  Your date is: 'red hair'"

  Scenario: Existing user tries to get some when they can't
    Given I am confirmed as "8004688487"
    And it it outside of the dating hours
    When I text instalover with "02108"
    Then I get a response telling me to try later

  Scenario: Existing users actually gets some
    Given it is within the dating hours
    And it is "8:00 PM"
    And "8004688487" is confirmed
    And we suggest "Silvertone" as a date place
    When "8004688487" texts instalover
    Then "8004688487" gets a response telling him to wait
    Given "6176060842" is confirmed
    When "6176060842" texts instalover
    Then "6176060842" gets a response telling him about a date with "8004688487" at "Silvertone" in 15 minutes
    And "8004688487" gets a response telling him about a date with "6176060842" at "Silvertone" in 15 minutes

  Scenario: Secret code reminder
    Given I am confirmed as "8004688487"
    When I go to the home page
    And I follow the link to resend my secret code
    And I press the button to resend my secret code
    Then I get a response telling me about my new secret key
    When I go to the home page
    And I follow the sign in link
    And i fill in my phone number as "8004688487"
    And I fill in my secret key
