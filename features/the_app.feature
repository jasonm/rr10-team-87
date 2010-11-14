Feature: The whole app

  Background:
    Given the following users exist:
      | Phone Number | Male | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Name  |
      | 11111111111  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | Mike  |
      | 12222222222  | true | false  | false            | true               | 10/20/1989   | 18                      | 34                      | Jason |
      | 18004688487  | false| true   | true             | false              | 12/31/1977   | 14                      | 22                      | Emma  |
    And the day and time is "October 16, 2010 8:00pm est"
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
      | Phone Number | Male | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Name  |
      | 13333333333  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | Mike  |
      | 14444444444  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | Mike  |
      | 15555555555  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | Mike  |
      | 16666666666  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | Mike  |
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Should we find you a date at Silvertone at 09:00PM? Reply 'ok' or 'new date' to try again."

    And there should be a meetup founded by "18004688487" that is "proposed"

    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "13333333333" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "14444444444" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "15555555555" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "16666666666" should not get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."

    And there should be a meetup founded by "18004688487" that is "unscheduled"

    When "11111111111" texts instalover with "accept"
    Then "12222222222" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    Then "13333333333" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    Then "14444444444" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    Then "15555555555" should get a text "Too slow! Would you like to get a date? Reply 'new date'."
    Then "16666666666" should not get a text "Too slow! Would you like to get a date? Reply 'new date'."
    And "11111111111" should get a text "Nice! You've got a date with Emma. Describe yourself using 'say' followed by a message."
    And "18004688487" should get a text "Nice! You've got a date with Mike. Describe yourself using 'say' followed by a message."

  Scenario: Existing user texts ok without having a proposed meetup
    When "18004688487" texts instalover with "ok"
    Then "18004688487" should get a text "Sorry, I don't know what to do with that. You can text 'new date' to get a date. To stop receiving texts, please text 'safeword'"

  Scenario: Existing user asks for a date, but they're picky
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Should we find you a date at Silvertone at 09:00PM? Reply 'ok' or 'new date' to try again."

    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Should we find you a date at Mike's Apartment at 09:00PM? Reply 'ok' or 'new date' to try again."

    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date with Emma at Mike's Apartment at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date with Emma at Mike's Apartment at 09:00PM? Reply 'accept' or ignore."

  Scenario: Existing user asks for a date outside of the dating hours
    Given it is outside of the dating hours
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Outside of the dating hours: 5PM EDT to 10:59PM EDT. Please try again then!"

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
    Then "11111111111" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."

    When "11111111111" texts instalover with "new date"
    And  "11111111111" texts instalover with "accept"
    Then "11111111111" should get a text whose message includes "You don't have any date offers to accept"

  Scenario: If you have an offer, you cannot receive a second one
    When "11111111111" texts instalover with "new date"
    And  "11111111111" texts instalover with "ok"
    Then "18004688487" should get a text whose message includes "Want to go on a date with Mike at Silvertone"

    When "12222222222" texts instalover with "new date"
    And  "12222222222" texts instalover with "ok"
    Then "18004688487" should not get a text whose message includes "Want to go on a date with Jason at Mike's Apartment"

  Scenario: Emma realizes that Chad cockblocked her
    Given the following users exist:
      | Phone Number | Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Name |
      | 16666666666  | true | true               | 11/06/1989   | 18                      | 34                      | Chad |
      | 13333333333  | true | true               | 11/06/1989   | 18                      | 34                      | Jim  |
      | 14444444444  | true | true               | 11/06/1989   | 18                      | 34                      | Jim  |
      | 15555555555  | true | true               | 11/06/1989   | 18                      | 34                      | Jim  |
      | 17777777777  | true | true               | 11/06/1989   | 18                      | 34                      | Jim  |
      | 18888888888  | true | true               | 11/06/1989   | 18                      | 34                      | Jim  |
      | 19999999999  | true | true               | 11/06/1989   | 18                      | 34                      | Jim  |
      | 10000000000  | true | true               | 11/06/1989   | 18                      | 34                      | Jim  |
      | 11111111112  | true | true               | 11/06/1989   | 18                      | 34                      | Jim  |
    When "18004688487" texts instalover with "new date"
    And "18004688487" texts instalover with "ok"
    Then "16666666666" should get a text whose message includes "Want to go on a date"
    But "15555555555" should not get a text whose message includes "Want to go on a date"
    When "16666666666" texts instalover with "accept"
    Given I clear the text message history
    When "18004688487" texts instalover with "new date"
    And "18004688487" texts instalover with "ok"
    Then "16666666666" should not get a text whose message includes "Want to go on a date"
    But "15555555555" should get a text whose message includes "Want to go on a date"

  Scenario: Existing user falls asleep before oking date location
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Should we find you a date at Silvertone at 09:00PM? Reply 'ok' or 'new date' to try again."

    When jobs in 5 minutes from now are processed
    Then "18004688487" should get a text "I guess you don't want to go on a date... Text 'new date' again when you change your mind"

  Scenario: Existing user times out after flicking through dates
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text whose message includes "Reply 'ok' or 'new date'"
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text whose message includes "Reply 'ok' or 'new date'"
    Then "18004688487" should have only one proposed meetup
    When jobs in 5 minutes from now are processed
    Then "18004688487" should get a text "I guess you don't want to go on a date... Text 'new date' again when you change your mind"
    And  "18004688487" should have no proposed meetups

  Scenario: User tries to get a new date while we're looking for people to accept
    When "18004688487" texts instalover with "new date"
    And "18004688487" texts instalover with "ok"

    Then "11111111111" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And  "12222222222" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."

    And there should be a meetup founded by "18004688487" that is "unscheduled"

    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Whoa there, pardner - we're looking for someone right now.  If nobody shows after 5 minutes, then you can ask again."

  Scenario: Unknown command handler
    When "18004688487" texts instalover with "all the dicks you can fit in your mouth?"
    Then "18004688487" should get a text "Sorry, I don't know what to do with that. You can text 'new date' to get a date. To stop receiving texts, please text 'safeword'"

  Scenario: Safeword
    When "18004688487" texts instalover with "safeword"
    Then "18004688487" should get a text "I got it - 'no' means no!  We could just be friends, but we're not fooling anyone.  You're unsubscribed - have a nice life!"
    And the "18004688487" user should be deleted

  Scenario: Safeword race condition with timing out offers
    When "18004688487" texts instalover with "new date"
    Then "18004688487" should get a text "Should we find you a date at Silvertone at 09:00PM? Reply 'ok' or 'new date' to try again."
    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    When "11111111111" texts instalover with "safeword"
    Then "11111111111" should get a text "I got it - 'no' means no!  We could just be friends, but we're not fooling anyone.  You're unsubscribed - have a nice life!"
    And the "11111111111" user should be deleted
    When jobs in 5 minutes from now are processed
    Then "11111111111" should not get a text "Too slow! Would you like to get a date? Reply 'new date'."

  Scenario: Texting something before you confirm
    When I go to the home page
    And I fill in "19998675309" as my phone number
    And I press the text me button
    And I clear the text message history
    And "19998675309" texts instalover with "new date"
    Then "19998675309" should get a text whose message includes "Before you can become an instalover you must know this secret code"
    And  "19998675309" should get a text whose message includes "Visit instalover.com to finish signing up."

  Scenario: Asking for a date with a woman
    Given the following users exist:
      | Phone Number | Male  | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Name  |
      | 16176060842  | false | true   | true             | true               | 11/06/1989   | 18                      | 34                      | Becca |
    When "18004688487" texts instalover with "woman"
    Then "18004688487" should get a text "Should we find you a date at Silvertone at 09:00PM? Reply 'ok' or 'new date' to try again."
    When "18004688487" texts instalover with "ok"
    Then "16176060842" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    But "11111111111" should not get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."

  Scenario: Asking for a date with a man
    Given the following users exist:
      | Phone Number | Male  | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Name  |
      | 16176060842  | false | true   | true             | true               | 11/06/1989   | 18                      | 34                      | Becca |
    When "18004688487" texts instalover with "man"
    Then "18004688487" should get a text "Should we find you a date at Silvertone at 09:00PM? Reply 'ok' or 'new date' to try again."
    When "18004688487" texts instalover with "ok"
    Then "11111111111" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    But "16176060842" should not get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."

  Scenario: Asking for a date with other
    Given the following users exist:
      | Phone Number | Male  | Female | Other | Looking For Male | Looking For Female | Looking For Other | Dob          | Looking For Minimum Age | Looking For Maximum Age | Name  |
      | 16176060842  | false | true   | false | true             | true               | true              | 11/06/1989   | 18                      | 34                      | Becca |
      | 16171231234  | false | false  | true  | true             | true               | true              | 11/06/1989   | 18                      | 34                      | Pat   |
    When "18004688487" texts instalover with "other"
    Then "18004688487" should get a text "Should we find you a date at Silvertone at 09:00PM? Reply 'ok' or 'new date' to try again."
    When "18004688487" texts instalover with "ok"
    Then "16171231234" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    But "16176060842" should not get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And "11111111111" should not get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."

  Scenario: Asking for a date with anything
    Given the following users exist:
      | Phone Number | Male  | Female | Other | Looking For Male | Looking For Female | Looking For Other | Dob          | Looking For Minimum Age | Looking For Maximum Age | Name  |
      | 16176060842  | false | true   | false | true             | true               | true              | 11/06/1989   | 18                      | 34                      | Becca |
      | 16171231234  | false | false  | true  | true             | true               | true              | 11/06/1989   | 18                      | 34                      | Pat   |
    When "18004688487" texts instalover with "whatever"
    Then "18004688487" should get a text "Should we find you a date at Silvertone at 09:00PM? Reply 'ok' or 'new date' to try again."
    When "18004688487" texts instalover with "ok"
    Then "16171231234" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And "16176060842" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."
    And "11111111111" should get a text "Want to go on a date with Emma at Silvertone at 09:00PM? Reply 'accept' or ignore."

  Scenario: User skeezes to increase the matches they can get
    Given the following users exist:
      | Phone Number | Male  | Female | Other | Looking For Male | Looking For Female | Looking For Other | Dob          | Looking For Minimum Age | Looking For Maximum Age | Name  |
      | 16669996669  | false | true   | false | true             | true               | true              | 09/08/1984   | 18                      | 30                      | Emma  |
      | 19991119991  | false | true   | false | false            | true               | false             | 11/06/1990   | 18                      | 30                      | Tatu  |
    When "16669996669" texts instalover with "woman"
    Then "16669996669" should get a text whose message includes "Should we find you a date"
    When "16669996669" texts instalover with "OK"
    Then "19991119991" should get a text whose message includes "Want to go on a date with Emma"
    When jobs in 5 minutes from now are processed
    Then "16669996669" should get a text whose message includes "every number in our little black book"
    When "16669996669" texts instalover with "woman"
    Then "16669996669" should get a text whose message includes "Should we find you a date"
    When "16669996669" texts instalover with "skeeze"
    Then "19991119991" should get a text whose message includes "Want to go on a date with Emma"
