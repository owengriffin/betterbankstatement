#!/usr/bin/ruby
# betterbankstatement.rb <folder> <port>
# <folder> = A folder containing either CSV, QIF or TXT files
# <port>   = An available port for the WEBrick server
require 'lib/betterbankstatement.rb'
require 'webrick'

folder = ARGV[0]
port = ARGV[1]

if folder == nil
  folder = 'data/'
end
if port == nil
  port = 8888
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

server = WEBrick::HTTPServer.new(:Port => port, :DocumentRoot => Dir.pwd)
trap("INT") { server.shutdown }
server.start
