#!/usr/bin/ruby
# betterbankstatement.rb <folder>
# <folder> = A folder containing bank statements
require 'lib/betterbankstatement.rb'

folder = ARGV[0]

if folder == nil
  puts "Please read README for usage"
  exit
end

parser = BetterBankStatement::Parser.new
Dir.foreach(folder) { |filename|
  if filename =~ /.*\.txt$/
    parser.open("#{folder}/#{filename}")
  elsif filename =~ /.*\.qif$/
    parser.open_qif("#{folder}/#{filename}")
  elsif filename =~ /.*\.csv/
    parser.open_csv("#{folder}/#{filename}")
  end
}

BetterBankStatement::Payee.load_filters("filters.yaml")
BetterBankStatement::Payee.categorize_all

BetterBankStatement::Statement.generate
