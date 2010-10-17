Feature: Scene 2: the morning after

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

  Scenario: Get a morning after text
    When "18004688487" texts instalover with "new date"
    And  "18004688487" texts instalover with "ok"
    And  "11111111111" texts instalover with "accept"

    When jobs tomorrow at 10am are processed

    Then "18004688487" should get a text "Hey Emma, how did it go last night with Mike?  Respond to this text to let us know."
    And  "11111111111" should get a text "Hey Mike, how did it go last night with Emma?  Respond to this text to let us know."

    When "18004688487" texts instalover with "Ohmygod best date evar"
    And  "11111111111" texts instalover with "Blew my mind"

    Then there should be a DFLN from "18004688487" about their most recent meetup that says "Ohmygod best date evar"
    And  there should be a DFLN from "11111111111" about their most recent meetup that says "Blew my mind"
