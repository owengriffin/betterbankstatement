# -*- coding: utf-8 -*-
$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'date'
require 'yaml'
require 'rubygems'
require 'csv'
require 'json'
require 'logger'
require 'dm-core'
require 'dm-aggregates'
require 'chronic'

require 'betterbankstatement/category.rb'
require 'betterbankstatement/import.rb'
require 'betterbankstatement/transaction.rb'
require 'betterbankstatement/filter.rb'
require 'betterbankstatement/time.rb'

# Set the database logging
DataMapper::Logger.new($stdout, :info)

# Declare the module and create a logger
module BetterBankStatement
  @log = Logger.new('/tmp/betterbankstatement.log')
  def self.log
    return @log
  end
  @dir = File.expand_path(File.dirname(__FILE__)) + "/betterbankstatement"
  def self.dir
    @dir
  end
  # Initialize the database connection
  def self.load(file=":memory:")
    DataMapper.setup(:default, "sqlite3:#{file}")
    DataMapper.auto_upgrade!
  end
end
