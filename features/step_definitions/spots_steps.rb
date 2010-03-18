Given /^the following managing_spots:$/ do |managing_spots|
  ManagingSpots.create!(managing_spots.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) managing_spots$/ do |pos|
  visit managing_spots_url
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following managing_spots:$/ do |expected_managing_spots_table|
  expected_managing_spots_table.diff!(tableish('table tr', 'td,th'))
end
