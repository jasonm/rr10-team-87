Feature: Admin event list
  Scenario: Visiting the events page for an encounter
    Given the following users exist:
      | Phone Number | Male | Female | Looking For Male | Looking For Female | Dob          | Looking For Minimum Age | Looking For Maximum Age | Description | Name  |
      | 11111111111  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
      | 12222222222  | true | false  | false            | true               | 10/20/1989   | 18                      | 34                      | black shirt | Jason |
      | 18004688487  | false| true   | true             | false              | 12/31/1977   | 14                      | 22                      | super hot   | Emma  |
      | 13333333333  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
      | 14444444444  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
      | 15555555555  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
      | 16666666666  | true | false  | false            | true               | 11/06/1989   | 18                      | 34                      | red hair    | Mike  |
    And the day and time is "October 16, 2010 8:00PM EDT"
    And the following date suggestions exist:
      | text             |
      | Silvertone       |
      | Mike's Apartment |
    And jobs are cleared
    And "18004688487" texts instalover with "new date"
    And the day and time is "October 16, 2010 8:03PM EDT"
    And "18004688487" texts instalover with "ok"
    And the day and time is "October 16, 2010 8:04PM EDT"
    And "11111111111" texts instalover with "accept"

    When I am on the secret events page

    Then I should see the following table:
      | Action        | Date              | Time   | From               | To                 | Information                                                   |
      | Incoming SMS  | Sat, Oct 16, 2010 | 8:00PM | Emma (18004688487) |                    | new date                                                      |
      | Incoming SMS  | Sat, Oct 16, 2010 | 8:03PM | Emma (18004688487) |                    | ok                                                            |
      | Date request  | Sat, Oct 16, 2010 | 8:03PM | Emma (18004688487) |                    | Silvertone at 09:00PM                                         |
      | Outgoing SMS  | Sat, Oct 16, 2010 | 8:03PM |                    | Mike (12222222222) | Want to go on a date with Emma at Silvertone at 09:00PM?      |
      | Outgoing SMS  | Sat, Oct 16, 2010 | 8:03PM |                    | Mike (13333333333) | Want to go on a date with Emma at Silvertone at 09:00PM?      |
      | Outgoing SMS  | Sat, Oct 16, 2010 | 8:03PM |                    | Mike (14444444444) | Want to go on a date with Emma at Silvertone at 09:00PM?      |
      | Outgoing SMS  | Sat, Oct 16, 2010 | 8:03PM |                    | Mike (15555555555) | Want to go on a date with Emma at Silvertone at 09:00PM?      |
      | Incoming SMS  | Sat, Oct 16, 2010 | 8:04PM | Emma (11111111111) |                    | accept                                                        |
      | Date accepted | Sat, Oct 16, 2010 | 8:04PM | Emma (18004688487) | Mike (11111111111) | Silvertone at 09:00PM                                         |
      | Outgoing SMS  | Sat, Oct 16, 2010 | 8:04PM | Emma (12222222222) |                    | Too slow! Would you like to get a date? Reply 'new date'.     |
      | Outgoing SMS  | Sat, Oct 16, 2010 | 8:04PM | Emma (13333333333) |                    | Too slow! Would you like to get a date? Reply 'new date'.     |
      | Outgoing SMS  | Sat, Oct 16, 2010 | 8:04PM | Emma (14444444444) |                    | Too slow! Would you like to get a date? Reply 'new date'.     |
      | Outgoing SMS  | Sat, Oct 16, 2010 | 8:04PM | Emma (15555555555) |                    | Too slow! Would you like to get a date? Reply 'new date'.     |
      | Outgoing SMS  | Sat, Oct 16, 2010 | 8:04PM | Emma (11111111111) |                    | Nice! You've got a date with Emma, 'super hot'. Say something |
      | Outgoing SMS  | Sat, Oct 16, 2010 | 8:04PM | Emma (18004688487) |                    | Nice! You've got a date with Mike, 'red hair'. Say something  |
