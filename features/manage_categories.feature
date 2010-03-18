Feature: Managing categories
  In order to have control over categories
  As a site administrator
  I want control who sees edit and destroy links
  
  Scenario Outline: Show/hide category links
    Given the following user records
      | email                  | password |
      | lenart.rudel@gmail.com | secret    |
      | user@gmail.com         | secret   |

    Given I am logged in as "<email>" with password "secret"
    And a category exists with name: "Javne tocke"
    When I go to path "<path>"
    Then I should see "Javne tocke"
    And I should <action>
  
    Examples:
      | email                  | path          | action            |
      | lenart.rudel@gmail.com | /categories   | see "Uredi"       |
      | user@gmail.com         | /categories   | not see "Uredi"   |
      |                        | /categories   | not see "Uredi"   |
      | lenart.rudel@gmail.com | /categories/1 | see "Uredi"       |
      | user@gmail.com         | /categories/1 | not see "Uredi"   |
      |                        | /categories/1 | not see "Uredi"   |
      | lenart.rudel@gmail.com | /categories/1 | see "Izbriši"     |
      | user@gmail.com         | /categories/1 | not see "Izbriši" |
      |                        | /categories/1 | not see "Izbriši" |