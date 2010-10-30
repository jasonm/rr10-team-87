Feature: Pre-arranged dates

  Scenario: Admin enters a date event and a member is offered it
    When I am on the secret date event index page
    And I follow "New date event"
    And I fill in "Name" with "ICA"
    And I fill in "Location" with "100 Northern Ave Boston, MA"
    And I fill in "Hours" with "5PM to 9PM"
    And I check "Thursday"
    And I press "Add"
    Then I see "Date even added"
