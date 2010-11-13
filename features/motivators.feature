Feature: Motivate people to use this service

  As of Nov 12, 2010:
  | total | no profile | asked for zero dates | asked for one date | asked for more than one date | have zero matches |
  | 109   | 49         | 81                   | 11                 | 17                           | 59, 77, 111       |
  User 59 is looking for other but we have no others
    Advertise to sex-positive communities?
  User 77 is looking for 18-21 y/o women
  User 111 is looking for 18-20 y/o women
    Advertise to college freshmen?

  Scenario: Annoy the people who have never filled out their profile
    Given the day and time is "November 12, 2010 01:00 est"
    Given the following empty user exists:
      | phone number | secret code |
      | 18004688487  | tits        |
    And the day and time is "November 18, 2010 01:00 est"
    Then "18004688487" should not get a text whose message includes "fill out"
    When it is 24 hours later
    And timed jobs are processed
    Then "18004688487" should get a text whose message includes "fill out"
    Given I clear the text message history
    When it is 24 hours later
    And timed jobs are processed
    Then "18004688487" should get a text whose message includes "fill out"

    When I go to the home page
    And I fill in "18004688487" as my phone number
    And I press the text me button
    And I fill in the secret code "tits"
    And I fill in the date of birth with "November 12, 1983"
    And I fill in my name as "Mike"
    And I check my gender as male
    And I fill in the minimum age with "21"
    And I fill in the maximum age with "34"
    And I check my desired gender as female
    And I submit my profile
    Then I see a welcome page

    Given I clear the text message history
    When it is 24 hours later
    And timed jobs are processed
    Then "18004688487" should not get a text whose message includes "fill out"

  @wip
  Scenario: Ask out those who have asked for one date on behalf of those who have asked out none
