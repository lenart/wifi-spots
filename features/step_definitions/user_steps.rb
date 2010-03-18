Given /^the following user records$/ do |table|
  table.hashes.each do |hash|
    User.make(:email => hash[:email], :password => hash[:password], :password_confirmation => hash[:password])
  end
end

Given /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  visit login_path
  fill_in "E-mail naslov", :with => email
  fill_in "Geslo", :with => password
  click_button "Prijavi se"
end