Feature: The whole app

  Background:
    Given the following users exist:
      | Phone Number | Male | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Description | Name  |
      | 11111111111  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
      | 12222222222  | true | false  | false            | true               | 10/20/1989   | 18                      | 34                      | black shirt | Jason |
      | 18004688487  | false| true   | true             | false              | 12/31/1977   | 14                      | 22                      | super hot   | Emma  |
    And the day and time is "October 16, 2010 8:00pm edt"
    And the following date suggestions exist:
      | text             |
      | Silvertone       |
      | Mike's Apartment |
    And jobs are cleared

  Scenario: An unregistered user tries to text instalover
    When "11234567890" texts instalover with "hey!!!"
    Then "11234567890" should get a text "Sorry, you must register first at instalover.com"

  Scenario: Existing user tries to get some and is happy with everything
    Given the following users exist:
      | Phone Number | Male | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Description | Name  |
      | 13333333333  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
      | 14444444444  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
      | 15555555555  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
      | 16666666666  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Silvertone at 09:00PM? Reply 'ok' or 'new date'."

    And there should be a meetup founded by "18004688487" that is "proposed"

    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "13333333333" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "14444444444" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "15555555555" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "16666666666" should not get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."

    And there should be a meetup founded by "18004688487" that is "unscheduled"

    When "11111111111" texts instalover with "accept"
    Then "12222222222" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    Then "13333333333" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    Then "14444444444" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    Then "15555555555" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    Then "16666666666" should not get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "11111111111" should get a text "Nice! You've got a date with Emma, whose self-description is: 'super hot'. Talk with your date by texting 'say ' with your message"
    And "18004688487" should get a text "Nice! You've got a date with Mike, whose self-description is: 'red hair'. Talk with your date by texting 'say ' with your message"

  Scenario: Existing user texts ok without having a proposed meetup
    When "18004688487" texts instalover with "ok"
    Then "18004688487" should get a text "Sorry, I don't know what to do with that. You can text 'new date' to get a date. To stop receiving texts, please text 'safeword'"

  Scenario: Existing user asks for a date, but they're picky
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Silvertone at 09:00PM? Reply 'ok' or 'new date'."

    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Mike's Apartment at 09:00PM? Reply 'ok' or 'new date'."

    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date at Mike's Apartment at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date at Mike's Apartment at 09:00PM? Reply 'accept' or ignore."

  Scenario: Existing user asks for a date outside of the dating hours
    Given it is outside of the dating hours
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Outside of the dating hours: 5PM to 11PM (EST). Please try again then!"

  Scenario: Once a user proposes a date, they can no longer receive offers
    When "18004688487" texts instalover with "new date"
    And  "11111111111" texts instalover with "new date"
    And  "18004688487" texts instalover with "ok"
    Then "11111111111" should not get a text whose message includes "Want to go on a date"

  Scenario: Once a user has an unscheduled date, they can no longer receive offers
    When "18004688487" texts instalover with "new date"
    And  "11111111111" texts instalover with "new date"
    And  "11111111111" texts instalover with "ok"
    And  "18004688487" texts instalover with "ok"
    Then "11111111111" should not get a text whose message includes "Want to go on a date"

  Scenario: If you have a scheduled date, you are now eligible for offers again since we consider you done with the date
    When "18004688487" texts instalover with "new date"
    And  "18004688487" texts instalover with "ok"
    And  "11111111111" texts instalover with "accept"

    And  "11111111111" texts instalover with "new date"
    And  "11111111111" texts instalover with "ok"

    Then "18004688487" should get a text whose message includes "Mike's Apartment"

  Scenario: Saying "new date" when you have an offer will delete your offer
    When "18004688487" texts instalover with "new date"
    And  "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."

    When "11111111111" texts instalover with "new date"
    And  "11111111111" texts instalover with "accept"
    Then "11111111111" should get a text whose message includes "You don't have any date offers to accept"

  Scenario: If you have an offer, you cannot receive a second one
    When "11111111111" texts instalover with "new date"
    And  "11111111111" texts instalover with "ok"
    Then "18004688487" should get a text whose message includes "Want to go on a date at Silvertone"

    When "12222222222" texts instalover with "new date"
    And  "12222222222" texts instalover with "ok"
    Then "18004688487" should not get a text whose message includes "Want to go on a date at Mike's Apartment"

  Scenario: Existing user asks for a date, but they get turned down
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "How about Silvertone at 09:00PM? Reply 'ok' or 'new date'."

    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."

    When jobs in 5 minutes from now are procedsed

    Then "18004688487" should get a text "We called every number in our little black book, but only got answering machines.  Try again later?  Reply 'new date' to start again."
    And "11111111111" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "12222222222" should get a text "Too slow! Would you like to get a date? Reply 'new date'."

    When I clear the text message history
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text whose message includes "Reply 'ok' or 'new date'."

    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text whose message includes "Want to go on a date"
    And  "12222222222" should get a text whose message includes "Want to go on a date"

  Scenario: User tries to get a new date while we're looking for people to accept
    When "18004688487" texts instalover with "new date"
    And "18004688487" texts instalover with "ok"

    Then "11111111111" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date at Silvertone at 09:00PM? Reply 'accept' or ignore."

    And there should be a meetup founded by "18004688487" that is "unscheduled"

    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Whoa there, partner - we're looking for someone right now.  If nobody shows after 5 minutes, then you can ask again."

  Scenario: Unknown command handler
    When "18004688487" texts instalover with "all the dicks you can fit in your mouth?"
    Then "18004688487" should get a text "Sorry, I don't know what to do with that. You can text 'new date' to get a date. To stop receiving texts, please text 'safeword'"

  Scenario: Safeword
    When "18004688487" texts instalover with "safeword"
    Then "18004688487" should get a text "I got it - 'no' means no!  We could just be friends, but we're not fooling anyone.  You're unsubscribed - have a nice life!"
    And the "18004688487" user should be deleted

  Scenario: Texting something before you confirm
    When I go to the home page
    And I fill in "19998675309" as my phone number
    And I press the text me button
    And I clear the text message history
    And "19998675309" texts instalover with "new date"
    Then "19998675309" should get a text whose message includes "Before you can become an instalover you must know this secret code"
    And  "19998675309" should get a text whose message includes "Visit instalover.com to finish signing up."
