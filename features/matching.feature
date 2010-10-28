Feature: Matching people up

  Background:
    Given the day and time is "October 16, 2010 8:00pm edt"
    And the following date suggestions exist:
      | text             |
      | Silvertone       |
      | Mike's Apartment |
    And jobs are cleared

  Scenario: People get what they want
    Given the following young people exist:
      | Phone Number | Male  | Female | Looking For Male | Looking For Female | Name          |
      | 11111111111  | false | true   | true             | true               | Bi girl       |
      | 12222222222  | true  | false  | true             | true               | Bi guy        |
      | 13333333333  | false | true   | true             | false              | Straight girl |
      | 14444444444  | true  | false  | false            | true               | Straight guy  |
      | 15555555555  | true  | false  | true             | false              | Gay guy one   |
      | 16666666666  | true  | false  | true             | false              | Gay guy two   |
      | 17777777777  | false | true   | false            | true               | Gay girl one  |
      | 18888888888  | false | true   | false            | true               | Gay girl two  |

    Then "Straight girl" should get matched with:
      | Straight guy |
      | Bi guy       |

    And "Straight guy" should get matched with:
      | Straight girl |
      | Bi girl       |

    And "Bi girl" should get matched with:
      | Straight guy |
      | Gay girl one |
      | Gay girl two |
      | Bi guy       |

    And "Bi guy" should get matched with:
      | Straight girl |
      | Gay guy one   |
      | Gay guy two   |
      | Bi girl       |

    And "Gay guy one" should get matched with:
      | Gay guy two |
      | Bi guy      |

    And "Gay guy two" should get matched with:
      | Gay guy one |
      | Bi guy      |

    And "Gay girl one" should get matched with:
      | Gay girl two |
      | Bi girl      |

    And "Gay girl two" should get matched with:
      | Gay girl one |
      | Bi girl      |
