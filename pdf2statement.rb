#!/bin/ruby
# -*- coding: utf-8 -*-

require 'date'
require 'yaml'
require 'rubygems'
require 'mechanize'
require 'net/http'
require 'net/https'
require 'rexml/document'
require 'google_chart'



$filters = YAML.load_file('filters.yaml')

class Transaction
  attr_accessor :received
  attr_accessor :date
  attr_accessor :details
  attr_accessor :amount

  @@regexp = /^\s*([0-9]{2}\s+[a-z]{3}\s+[0-9]{2})\s+([0-9]{2}\s+[a-z]{3}\s+[0-9]{2})\s+(.+)\s+([0-9\.]+(?:CR)?)\s*$/mi

  def initialize(content)
    match = content.match(@@regexp)
    if match
      @received = Date.strptime(match[1], '%d %b %y')
      @date = Date.strptime(match[2], '%d %b %y')
      @details = match[3].gsub(/\s+$/,'')
      self.amount = match[4]
    else
      puts "I don't understand #{content}"
    end
  end

  def amount=(a)
    if a =~ /^[0-9\.]+CR$/
      @amount = a[0...a.length-2].to_f
    else
      @amount = a.to_f * -1
    end
  end

  def category
    $filters.each { |filter|
      if @details =~ filter[:expression]
        return filter[:category]
      end
    }
    puts "Unknown category for #{@details} amount = #{@amount}"
    return "Unknown"
  end

  def self.regexp
    return @@regexp
  end
end


transactions=[]
Dir.foreach("statements") { |filename|
  if filename =~ /.*\.txt$/
    puts filename
    File.open("statements/#{filename}") do |file|
      while content = file.gets
        if content =~ Transaction::regexp
          transactions << Transaction.new(content)
        end
      end
    end
  end
}


# Sort the statements by received date
#t=transactions.sort { |x,y| x.received <=> y.received }
# Convert the transactions to Homebank CSV format
#t.each {|transaction| 
#puts "#{transaction.date.strftime('%d/%m/%Y')};0;;#{transaction.details};;#{transaction.amount};#{transaction.category}"
#}

class Category
  attr_accessor :name
  attr_accessor :transactions

  def initialize(name)
    @name = name
    @transactions = []
  end

  def transactions
    return @transactions
  end

  def total_amount
    total = 0
    @transactions.each { |transaction|
      total += transaction.amount
    }
    return total
  end

  def total_negative
    total = 0
    @transactions.each { |transaction|
      total += transaction.amount if transaction.amount < 0
    }
    return total
  end

  @@categories = []
  def Category.get_by_name(name)
    @@categories.each { |category|
      return category if category.name == name
    }
    return nil
  end

  def Category.create(name)
    category = Category.new(name)
    @@categories << category
    return category
  end

  def Category.all
    return @@categories
  end

  def Category.total_amount
    total = 0
    @@categories.each { |category| total += category.total_amount }
    return total
  end

  def Category.total_negative
    total = 0
    @@categories.each { |category| total += category.total_negative }
    return total
  end
end

categories = [];

transactions.each { |transaction|
  category_name = transaction.category
  category = Category.get_by_name(category_name)
  category = Category.create(category_name) if category == nil
  category.transactions << transaction
}

Category.all.each { |category|
  puts "#{category.name} #{category.transactions.length} #{category.total_amount}"
}
total = Category.total_amount
puts "#{total}"

GoogleChart::PieChart.new('680x400', "Analysis of spending",false) do |chart|

  Category.all.each { |category|
    amount = category.total_negative * -1
    chart.data "#{category.name} (£#{amount})", amount if amount > 0
  }
  
  puts chart.to_escaped_url
  uri = URI.parse(chart.to_escaped_url)
  Net::HTTP.start(uri.host) { |http|
    resp = http.get("#{uri.path}?#{uri.query}")
    open("piechart.png", "wb") { |file|
      file.write(resp.body)
    }
  }
end

colours=['660000', '006600', '000066', '660033', '336600', '003366', '660066', '666600', '006666']
#t=transactions.sort { |x,y| x.received <=> y.received }
GoogleChart::BarChart.new('680x400', "Analysis of spending", :vertical, false) do |chart|

  colour_index = 0
  categories = Category.all.sort { |x,y| x.total_negative <=> y.total_negative}
  categories.each { |category|
    amount = category.total_negative * -1
    chart.data "#{category.name} (£#{amount})", [amount], colours[colour_index] if amount > 0
    colour_index = colour_index + 1
  }
  
  puts chart.to_escaped_url
  uri = URI.parse(chart.to_escaped_url)
  Net::HTTP.start(uri.host) { |http|
    resp = http.get("#{uri.path}?#{uri.query}")
    open("barchart.png", "wb") { |file|
      file.write(resp.body)
    }
  }
end

