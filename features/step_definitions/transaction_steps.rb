Given /^I create a transaction of "([^\"]*)" on "([^\"]*)" costing "([^\"]*)" in category "([^\"]*)"$/ do |arg1, arg2, arg3, arg4|
  BetterBankStatement::Transaction.new(:amount => arg3.to_i, :date => Chronic.parse(arg2), :description => arg1, :category => BetterBankStatement::Category.first(:name => arg4)).save
end

Given /^I create a transaction of "([^\"]*)" on "([^\"]*)" costing "([^\"]*)"$/ do |arg1, arg2, arg3|
  BetterBankStatement::Transaction.new(:amount => arg3.to_i, :date => Chronic.parse(arg2), :description => arg1).save
end

Then /^the transaction with the name "([^\"]*)" costing "([^\"]*)" will be returned$/ do |arg1, arg2|
  fail if arg1 != $result.description
  fail if arg2.to_s != $result.amount.to_s
end

Then /^the total number of transactions should be "([^\"]*)"$/ do |arg1|
  fail if BetterBankStatement::Transaction.count != arg1.to_i
end

Then /^there is a transaction "([^\"]*)" of "([^\"]*)" on "([^\"]*)"$/ do |arg1, arg2, arg3|
  date = Chronic.parse(arg3).to_date
count = BetterBankStatement::Transaction.count(:description => arg1, :amount => arg2, :date => (date..date+1))
  fail if count == 0
end

When /^I find the earliest transaction$/ do
  $result = BetterBankStatement::Transaction.earliest
end
