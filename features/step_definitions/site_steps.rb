
When /^I visit the "([^\"]*)" page$/ do |arg1|
  if arg1 == "Import"
    url = "import"
  elsif arg1 == "Transactions"
    url = "transactions"
  elsif arg1 == "Filters"
    url = "filters"
  elsif arg1 == "Categories"
    url = "categories"
  elsif arg1 == "Home"
    url = ""
  end
  visit "http://localhost:4567/#{url}"
end

Then /^I should (not )?see a list of categories$/ do |arg1|
  found = have_selector("#category_list").matches?(response_body) 
  fail if found and arg1 == "not"
  fail if not found and arg1 == ""
end

Then /^I should (not )?see a list of filters$/ do |arg1|
  found = have_selector("#filter_list").matches?(response_body) 
  fail if found and arg1 == "not"
  fail if not found and arg1 == ""
end

Then /^I should (not )?see the text "([^\"]*)"$/ do |arg1, arg2|
  if arg1 == nil or arg1.empty?
    assert_contain arg2
  else
    assert_not_contain arg2
  end
end

Then /^I am on the "([^\"]*)" page$/ do |arg1|
  fail if current_url != arg1
end

When /^I click on the "([^\"]*)" link$/ do |arg1|
  click_link arg1
end

When /^I upload a file to "([^\"]*)" with the content$/ do |arg1, string|
  filename = '/tmp/upload.tmp'
  File.open(filename, 'w') {|f| f.write(string) }
  attach_file arg1, filename
end

When /^I upload the filter file with the content$/ do |string|
  filename = '/tmp/filter.tmp'
  File.open(filename, 'w') {|f| f.write(string) }
  attach_file 'import_file', filename
end

Then /^I fill in "([^\"]*)" with "([^\"]*)"$/ do |arg1, arg2|
  fill_in arg1, :with => arg2
end

When /^I hit the "([^\"]*)" button$/ do |arg1|
  click_button arg1
end

Then /^I should select "([^\"]*)"$/ do |arg1|
  check arg1
end


Then /^I should receive the content "(.*)"$/ do |arg1|
  assert_equal arg1, response_body
end


Given /^I create the filter matching "([^\"]*)" for the category "([^\"]*)"$/ do |arg1, arg2|
  When "I visit the \"Filters\" page"
  When "I click on the \"New Filter\" link"
  Then "I should see the text \"Transaction containing:\""
  Then "I fill in \"expression\" with \"#{arg1}\""
  Then "I fill in \"category\" with \"#{arg2}\""
  When "I hit the \"Create\" button"
  Then "I should see the text \"Filter created successfully\""
end


