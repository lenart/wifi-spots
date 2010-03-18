Feature: Custom navigation
  In order to ease work
  As a administrator
  I want custom navigation
  
  Scenario Outline: Show advanced links
    Given a user exists with email: "<email>", password: "secret", password_confirmation: "secret"
    And I am logged in as "<email>" with password "secret"
    When I go to spots index page
    Then I should <action>
    
    Examples:
      | email                  | action              |
      | lenart.rudel@gmail.com | see "Uvozi RSS"     |
      | marko@o2z2.com         | not see "Uvozi RSS" |

