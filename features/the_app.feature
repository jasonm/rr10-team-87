Feature: The whole app

  Background:
    Given the following users exist:
      | Phone Number | Male | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Description |
      | 11111111111  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    |
      | 12222222222  | true | false  | false            | true               | 10/20/1989   | 18                      | 34                      | black shirt |
      | 18004688487  | false| true   | true             | false              | 12/31/1977   | 14                      | 22                      | super hot   |
    And the day and time is "October 16, 2010 8:00pm edt"
    And the following date suggestions exist:
      | text             |
      | Silvertone       |
      | Mike's Apartment |

  Scenario: An unregistered user tries to text instalover
    When "11234567890" texts instalover with "hey!!!"
    Then "11234567890" should get a text "You must register first at instalover.com"

  Scenario: Existing user tries to get some and is happy with everything
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Silvertone at 09:00PM? Reply 'ok' or 'new date'."

    And there should be a meetup founded by "18004688487" that is "proposed"

    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."

    And there should be a meetup founded by "18004688487" that is "unscheduled"

    When "11111111111" texts instalover with "accept"
    Then "12222222222" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "11111111111" should get a text "You got it! Meet at Silvertone at 09:00PM. Your date is: 'super hot'"
    And "18004688487" should get a text "You got it! Meet at Silvertone at 09:00PM. Your date is: 'red hair'"

  Scenario: Existing user texts ok without having a proposed meetup
    When "18004688487" texts instalover with "ok"
    Then "18004688487" should get a text "Please text 'new date' for a new date. To stop receiving texts, please text 'safeword'"

  Scenario: Existing user asks for a date, but they're picky
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Silvertone at 09:00PM? Reply 'ok' or 'new date'."

    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Mike's Apartment at 09:00PM? Reply 'ok' or 'new date'."

    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date at Mike's Apartment at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date at Mike's Apartment at 09:00PM? Reply 'accept' or ignore."


  Scenario: Once a user proposes a date, they can no longer receive other date proposals
    When "18004688487" texts instalover with "new date"
    And "11111111111" texts instalover with "new date"
    And "18004688487" texts instalover with "ok"
    And "11111111111" texts instalover with "ok"
    Then "18004688487" should not get a text whose message includes "Want to go on a date"

  Scenario: Saying "new date" when you have an offer will delete your offer
    When "18004688487" texts instalover with "new date"
    And "18004688487" texts instalover with "ok"

    Then "11111111111" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."

    When "11111111111" texts instalover with "new date"
    And "11111111111" texts instalover with "accept"

    Then "11111111111" should get a text whose message includes "You don't have any date offers to accept"

  Scenario: If you have an offer, you cannot receive a second one
    When "11111111111" texts instalover with "new date"
    And  "11111111111" texts instalover with "ok"
    Then "18004688487" should get a text whose message includes "Want to go on a date at Silvertone"

    And  "12222222222" texts instalover with "new date"
    When "12222222222" texts instalover with "ok"
    Then "18004688487" should not get a text whose message includes "Want to go on a date at Mike's Apartment"


  @wip
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

  Scenario: User tries to get a new date while we're looking for people to accept
    When "18004688487" texts instalover with "new date"
    And "18004688487" texts instalover with "ok"

    Then "11111111111" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."

    And there should be a meetup founded by "18004688487" that is "unscheduled"

    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Whoa there, partner - we're looking for someone right now.  If nobody shows after 5 minutes, then you can ask again."

  @wip
  Scenario: Unknown command handler
    When "18004688487" texts instalover with "all the dicks you can fit in your mouth?"
    Then "18004688487" should get a text "Sorry dear, I don't know what you mean - if you're waiting to hear about your date, hang tight.  Otherwise, reply 'new date' to get a date!"

  @wip
  Scenario: Edge case: user texts a command e.g. 'new date' after entering their phone number but before confirming - what happens?
