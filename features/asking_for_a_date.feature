Feature: Asking for a date

  Background:
    Given the following users exist:
      | Phone Number | Male | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Description | Name  |
      | 11111111111  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
      | 12222222222  | true | false  | false            | true               | 10/20/1989   | 18                      | 34                      | black shirt | Jason |
      | 18004688487  | false| true   | true             | false              | 12/31/1977   | 14                      | 22                      | super hot   | Emma  |
    Given the following users exist:
      | Phone Number | Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age |
      | 13333333333  | true | true               | 11/06/1989   | 18                      | 34                      |
      | 14444444444  | true | true               | 11/06/1989   | 18                      | 34                      |
      | 15555555555  | true | true               | 11/06/1989   | 18                      | 34                      |
      | 16666666666  | true | true               | 11/06/1989   | 18                      | 34                      |
      | 17777777777  | true | true               | 11/06/1989   | 18                      | 34                      |
      | 18888888888  | true | true               | 11/06/1989   | 18                      | 34                      |
      | 19999999999  | true | true               | 11/06/1989   | 18                      | 34                      |
      | 10000000000  | true | true               | 11/06/1989   | 18                      | 34                      |
      | 11111111112  | true | true               | 11/06/1989   | 18                      | 34                      |
    And the day and time is "October 16, 2010 8:00pm est"
    And the following date suggestions exist:
      | text             |
      | Silvertone       |
      | Mike's Apartment |
    And jobs are cleared
    And I clear the text message history

  Scenario: People ask for dates
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Should we find you a date at Silvertone at 09:00PM? Reply 'ok' or 'new date' to try again."
       
    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "13333333333" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "14444444444" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "15555555555" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    But  "16666666666" should not get a text whose message includes "Want to go on a date"

    When jobs in 5 minutes from now are processed

    Then "18004688487" should get a text "We called every number in our little black book, but only got answering machines. Try again with 'retry'."
    And "11111111111" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "12222222222" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "13333333333" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "14444444444" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "15555555555" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    But "16666666666" should not get a text whose message includes "Too slow!"

    Given I clear the text message history
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text whose message includes "Reply 'ok' or 'new date'"
    When "18004688487" texts instalover with "ok"
    Then "11111111111" should not get a text whose message includes "Want to go on a date"
    And  "12222222222" should not get a text whose message includes "Want to go on a date"
    And  "13333333333" should not get a text whose message includes "Want to go on a date"
    And  "14444444444" should not get a text whose message includes "Want to go on a date"
    And  "15555555555" should not get a text whose message includes "Want to go on a date"
    But  "16666666666" should get a text whose message includes "Want to go on a date"

    Given jobs in 5 minutes from now are processed
    And I clear the text message history
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text whose message includes "Reply 'ok' or 'new date'"
    When "18004688487" texts instalover with "ok"
    Then "11111111111" should not get a text whose message includes "Want to go on a date"
    And  "12222222222" should not get a text whose message includes "Want to go on a date"
    And  "13333333333" should not get a text whose message includes "Want to go on a date"
    And  "14444444444" should not get a text whose message includes "Want to go on a date"
    And  "15555555555" should not get a text whose message includes "Want to go on a date"
    And  "16666666666" should not get a text whose message includes "Want to go on a date"
    But  "11111111112" should get a text whose message includes "Want to go on a date"

    Given jobs in 5 minutes from now are processed
    And it is 1 hour later
    And I clear the text message history
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text whose message includes "Reply 'ok' or 'new date'"
    When "18004688487" texts instalover with "ok"

  Scenario: Ask for a date then retry
    When "18004688487" texts instalover with "new date"
    And "18004688487" texts instalover with "ok"
    And jobs in 5 minutes from now are processed
    Then "18004688487" should get a text "We called every number in our little black book, but only got answering machines. Try again with 'retry'."
    And "11111111111" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    Given I clear the text message history
    When "18004688487" texts instalover with "retry"
    Then "11111111111" should not get a text whose message includes "Want to go on a date"
    And  "12222222222" should not get a text whose message includes "Want to go on a date"
    And  "13333333333" should not get a text whose message includes "Want to go on a date"
    And  "14444444444" should not get a text whose message includes "Want to go on a date"
    And  "15555555555" should not get a text whose message includes "Want to go on a date"
    But  "16666666666" should get a text whose message includes "Want to go on a date"
    And  "18004688487" should get a text "Trying to get you a date. Back in five."

  Scenario: Asking for a retry when you haven't even tried
    When "18004688487" texts instalover with "retry"
    Then "18004688487" should get a text "Should we find you a date at Silvertone at 09:00PM? Reply 'ok' or 'new date' to try again."
