Feature: Managing spots
  In order to enable users to collaborate
  As a site visitor
  I want them to be able to add and edit spots
  
  Scenario Outline: Show/hide edit links
    Given the following user records
      | email                  | password |
      | lenart.rudel@gmail.com | secret    |
      | user@gmail.com         | secret   |

    Given I am logged in as "<email>" with password "secret"
    And a spot exists with title: "WiFi tocka"
    When I go to the show page for that spot
    Then I should see "WiFi tocka"
    And I should <action>
  
    Examples:
      | email                  | path     | action      |
      | lenart.rudel@gmail.com | /spots/1 | see "Uredi" |
      | user@gmail.com         | /spots/1 | see "Uredi" |
      |                        | /spots/1 | see "Uredi" |
      | lenart.rudel@gmail.com | /spots/1 | see "Izbriši" |
      | user@gmail.com         | /spots/1 | not see "Izbriši" |
      |                        | /spots/1 | not see "Izbriši" |

  Scenario: Delete own spots
    Given a user exists with email: "guest@gmail.com", password: "secret", password_confirmation: "secret"
    And a spot exists with user: the user
    And I am logged in as "guest@gmail.com" with password "secret"
    When I go to the show page for that spot
    Then I should see "Izbriši"
  
  
  