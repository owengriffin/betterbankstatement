Given /^I create a filter matching "([^\"]*)" for category "([^\"]*)"$/ do |arg1, arg2|
  BetterBankStatement::Filter.new(:expression => arg1, :category => BetterBankStatement::Category.first(:name => arg2)).save  
end

When /^I filter the transactions$/ do
  BetterBankStatement::Transaction.filter
end

Given /^I import the filter file "([^\"]*)"$/ do |arg1|
  BetterBankStatement::Filter.import arg1
end
