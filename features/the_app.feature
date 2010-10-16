Feature: The whole app

  Background:
    Given the following users exist:
      | Phone Number | Male | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Description |
      | 1111111111   | yes  | no     | no               | yes                | 11-06-1983   | 18                      | 34                      | red hair    |
      | 2222222222   | no   | yes    | yes              | no                 | 10-20-1983   | 18                      | 34                      | black shirt |
      | 8004688487   | yes  | yes    | yes              | yes                | 12-31-1977   | 14                      | 22                      | super hot   |
    And the time is "8:00 pm"
    And we suggest dates at:
      | Date             |
      | Silvertone       |
      | Mike's Apartment |

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

  Scenario: New user fails to enter the proper secret code

  @wip
  Scenario: Existing user tries to get some and is happy with everything
    When "8004688487" texts instalover with "new date"
    Then "8004688487" should get a text "How about Silvertone at 9:00 pm? Reply 'ok' or 'new date'."

    When "8004688487" texts instalover with "ok"
    Then "1111111111" should get a text "Want to go on a date at Silvertone at 9:00 pm? Reply 'accept' or ignore."
    And  "2222222222" should get a text "Want to go on a date at Silvertone at 9:00 pm? Reply 'accept' or ignore."

    When "1111111111" texts instalover with "accept"
    Then "2222222222" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "1111111111" should get a text "You got it! Meet at Silvertone at 9:00 pm. Your date is: 'super hot'"
    And "8004688487" should get a text "You got it! Meet at Silvertone at 9:00 pm. Your date is: 'red hair'"

  @later
  Scenario: Existing user asks for a date, but they're picky
    When "8004688487" texts instalover with "new date"
    Then "8004688487" should get a text "How about Silvertone at 9:00? Reply 'ok' or 'new date'."

    When "8004688487" texts instalover with "new date"
    Then "8004688487" should get a text "How about Mike's Apartment at 9:00? Reply 'ok' or 'new date'."

  @later
  Scenario: Existing user asks for a date, but they get turned down
    When "8004688487" texts instalover with "new date"
    Then "8004688487" should get a text "How about Silvertone at 9:00 pm? Reply 'ok' or 'new date'."

    When "8004688487" texts instalover with "ok"
    Then "1111111111" should get a text "Want to go on a date at Silvertone at 9:00 pm? Reply 'accept' or ignore."
    And  "2222222222" should get a text "Want to go on a date at Silvertone at 9:00 pm? Reply 'accept' or ignore."

    When 15 minutes go by
    And the lazy people checker runs

    Then "8004688487" should get a text "We called every number in our little black book, but only got answering machines.  Try again later?  Reply 'new date' to start again."
    And "1111111111" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "2222222222" should get a text "Too slow! Would you like to get a date? Reply 'new date'."

  @later
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
