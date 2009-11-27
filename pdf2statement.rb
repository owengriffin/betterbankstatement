#!/bin/ruby

require 'date'
require 'yaml'

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
    return ""
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
t=transactions.sort { |x,y| x.received <=> y.received }
# Convert the transactions to Homebank CSV format
t.each {|transaction| 
puts "#{transaction.date.strftime('%d/%m/%Y')};0;;#{transaction.details};;#{transaction.amount};#{transaction.category}"
}
