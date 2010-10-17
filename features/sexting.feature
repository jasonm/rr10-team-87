Feature: Users texting each other through us

  Scenario: Two users sext through us
    Given the following two users are scheduled to date:
      | 18004688487 | Alice |
      | 16176060842 | Bob   |
    When "18004688487" texts instalover with "Say wanna meet in my bed instead?"
    Then "16176060842" should get a text "Alice says: wanna meet in my bed instead?"

  Scenario: Lonely dude sexts through us
    Given "18004688487" is a confirmed user
    When "18004688487" texts instalover with "Say wanna meet in my bed instead?"
    Then "18004688487" should get a text "You have no date for us to share that with. Reply with 'new date'."
