Feature: The whole app

  Background:
    Given the following users exist:
      | Phone Number | Male | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Description |
      | 11111111111   | yes  | no     | no               | yes                | 11/06/1983   | 18                      | 34                      | red hair    |
      | 12222222222   | no   | yes    | yes              | no                 | 10/20/1983   | 18                      | 34                      | black shirt |
      | 18004688487   | yes  | yes    | yes              | yes                | 12/31/1977   | 14                      | 22                      | super hot   |
    And the day and time is "October 16, 2010 8:00pm EDT"
    And the following date suggestions exist:
      | text             |
      | Silvertone       |
      | Mike's Apartment |

  Scenario: An unregistered user tries to text instalover
    When "11234567890" texts instalover with "hey!!!"
    Then "11234567890" should get a text "You must register first at instalover.com"

  @wip
  Scenario: Existing user tries to get some and is happy with everything
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Silvertone at 09:00PM? Reply 'ok' or 'new date'."

    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."

    When "11111111111" texts instalover with "accept"
    Then "12222222222" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "11111111111" should get a text "You got it! Meet at Silvertone at 09:00PM. Your date is: 'super hot'"
    And "18004688487" should get a text "You got it! Meet at Silvertone at 09:00PM. Your date is: 'red hair'"

  Scenario: Existing user asks for a date, but they're picky
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Silvertone at 09:00PM? Reply 'ok' or 'new date'."

    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Mike's Apartment at 09:00PM? Reply 'ok' or 'new date'."

  @later
  Scenario: Existing user asks for a date, but they get turned down
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Silvertone at 09:00PM? Reply 'ok' or 'new date'."

    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."

    When 15 minutes go by
    And the lazy people checker runs

    Then "18004688487" should get a text "We called every number in our little black book, but only got answering machines.  Try again later?  Reply 'new date' to start again."
    And "11111111111" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "12222222222" should get a text "Too slow! Would you like to get a date? Reply 'new date'."

  @later
  Scenario: User tries to get a new date while we're looking for people to accept
    # What a jerk
    # Tell them no

  @later
  Scenario: Unknown command handler
    When "18004688487" texts instalover with "all the dicks you can fit in your mouth?"
    Then "18004688487" should get a text "Sorry dear, I don't know what you mean - if you're waiting to hear about your date, hang tight.  Otherwise, reply 'new date' to get a date!"
