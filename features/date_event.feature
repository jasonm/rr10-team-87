Feature: Pre-arranged dates

  The ICA is free from 5PM to 9PM on Thursdays
  JP Licks on Newbury is open from 11AM to midnight daily
  Mojitos has dance lessons on Fridays from 9PM to 2AM
  Shakespeare on the Common ran July 28 to August 15th, 2010
    8PM on Tuesday to Saturday and 7PM on Sunday

  Scenario: Admin enters a date event and a member is offered it
    When I am on the secret date event index page
    And I follow "New date event"
    And I fill in "Name" with "ICA"
    And I fill in "Location" with "100 Northern Ave Boston, MA"
    And I fill in "Hours" with "5PM to 9PM"
    And I check "Thursday"
    And I press "Add"
    Then I see "Date even added"
    # ...
