
Given /^I have no previous data$/ do
  BetterBankStatement::Category.all.each do |category|
    category.destroy!
  end
  fail if BetterBankStatement::Category.count > 0
  BetterBankStatement::Transaction.all.each do |transaction|
    transaction.destroy!
  end
  fail if BetterBankStatement::Transaction.count > 0
  BetterBankStatement::Filter.all.each do |filter|
    filter.destroy!
  end
  fail if BetterBankStatement::Filter.count > 0
end

Then /^"([^\"]*)" will be returned$/ do |arg1|
#  puts $result
#  puts arg1
  assert_equal arg1, $result.to_s
#  fail if $result.to_s != arg1.to_s
end
