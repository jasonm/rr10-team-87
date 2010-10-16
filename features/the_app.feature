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
  Scenario: Unknown command handler
    When "8004688487" texts instalover with "all the dicks you can fit in your mouth?"
    Then "8004688487" should get a text "Sorry dear, I don't know what you mean - if you're waiting to hear about your date, hang tight.  Otherwise, reply 'new date' to get a date!"
