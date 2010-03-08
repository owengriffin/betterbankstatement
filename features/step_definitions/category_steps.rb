 
Given /^I create a category called "([^\"]*)"$/ do |arg1|
  BetterBankStatement::Category.new(:name => arg1).save
end

When /^I get the category called "([^\"]*)"$/ do |arg1|
  $result = BetterBankStatement::Category.first(:name => arg1)
end

Then /^the category "([^\"]*)" will be returned$/ do |arg1|
  fail if $result.name != arg1
end

When /^I list all categories$/ do
  $result = BetterBankStatement::Category.all
end

Then /^a list with the category "([^\"]*)" will be returned$/ do |arg1|
  fail if $result.first(:name => arg1) == nil
end

When /^I calculate the total all transactions in the "([^\"]*)" category$/ do |arg1|
  $result = BetterBankStatement::Category.first(:name => arg1).total_amount
end

When /^I calculate the credit of all transactions of category "([^\"]*)"$/ do |arg1|
  $result = BetterBankStatement::Category.first(:name => arg1).credit
end

When /^I calculate the debit of all transactions of category "([^\"]*)"$/ do |arg1|
  $result = BetterBankStatement::Category.first(:name => arg1).debit
end

When /^I calculate the total of all transactions between "([^\"]*)" and "([^\"]*)" in the "([^\"]*)" category$/ do |arg1, arg2, arg3|
   $result = BetterBankStatement::Category.first(:name => arg3).total_amount(Chronic.parse(arg1)..Chronic.parse(arg2))
end

When /^I calculate the total amount debited of all transactions between "([^\"]*)" and "([^\"]*)" in the "([^\"]*)" category$/ do |arg1, arg2, arg3|
   $result = BetterBankStatement::Category.first(:name => arg3).debit(Chronic.parse(arg1)..Chronic.parse(arg2))
end

When /^I calculate the total amount credited of all transactions between "([^\"]*)" and "([^\"]*)" in the "([^\"]*)" category$/ do |arg1, arg2, arg3|
   $result = BetterBankStatement::Category.first(:name => arg3).credit(Chronic.parse(arg1)..Chronic.parse(arg2))
end

When /^I calculate the average amount spent on a transaction in the "([^\"]*)" category$/ do |arg1|
  $result = BetterBankStatement::Category.first(:name => arg1).average
end

When /^I calculate the average amount spent on a transactions between "([^\"]*)" and "([^\"]*)" in the "([^\"]*)" category$/ do |arg1, arg2, arg3|
   $result = BetterBankStatement::Category.first(:name => arg3).average(Chronic.parse(arg1)..Chronic.parse(arg2))
end

When /^I calculate the monthly average spent on the "([^\"]*)" category$/ do |arg1|
   $result = BetterBankStatement::Category.first(:name => arg1).monthly_average
end

When /^I find the earliest transaction in the category "([^\"]*)"$/ do |arg1|
  $result = BetterBankStatement::Category.first(:name => arg1).earliest
end

Then /^the category "([^\"]*)" will contain the transaction "([^\"]*)" costing "([^\"]*)"$/ do |arg1, arg2, arg3|
   category = BetterBankStatement::Category.first(:name => arg1)
   count = category.transactions.count(:description => arg2, :amount => arg3)
  fail if  count == 0
end
