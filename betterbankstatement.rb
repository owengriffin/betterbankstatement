#!/usr/bin/ruby
# betterbankstatement.rb <folder>
# <folder> = A folder containing bank statements
require 'lib/betterbankstatement.rb'

parser = BetterBankStatement::Parser.new
Dir.foreach(ARGV[0]) { |filename|
  if filename =~ /.*\.txt$/
    parser.open("#{ARGV[0]}/#{filename}")
  elsif filename =~ /.*\.qif$/
    parser.open_qif("#{ARGV[0]}/#{filename}")
  elsif filename =~ /.*\.csv/
    parser.open_csv("#{ARGV[0]}/#{filename}")
  end
}

BetterBankStatement::Payee.load_filters("filters.yaml")
BetterBankStatement::Payee.categorize_all

BetterBankStatement::Statement.generate
