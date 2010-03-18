Given /^the following spots:$/ do |spots|
  Spot.create!(spots.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) spot$/ do |pos|
  visit spots_url
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following spots:$/ do |expected_spots_table|
  expected_spots_table.diff!(tableish('table tr', 'td,th'))
end
