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
require 'markaby'
require 'hpricot'
require 'csv'

module HSBCChart

  class Parser
    STATEMENT_LINE_REGEXP=/^\s*([0-9]{2}\s+[a-z]{3}\s+[0-9]{2})\s+([0-9]{2}\s+[a-z]{3}\s+[0-9]{2})\s+(.+)\s+([0-9\.]+(?:CR)?)\s*$/mi
    LOCATION_REGEXP=/.*\s(.*\s.*)$/
    PAYEE_REGEXP=/^(.*)(\s.*\s.*)?$/
    ACCOUNT_REGEXP=/([A-Z ]+)\s+([0-9]{4} [0-9]{4} [0-9]{4} [0-9]{4})/
    CREDIT_LIMIT_REGEXP=/Credit Limit\s+£\s?([0-9,.])*/

    def get_location(details)
      details.match(LOCATION_REGEXP)[1] if details =~ LOCATION_REGEXP
    end

    def get_payee(description)
      s = description.split
      return s[0..s.length / 2].join " "
    end

    def get_amount(amount)
      if amount =~ /^[0-9\.]+CR$/
        return amount[0...amount.length-2].to_f
      elsif amount =~ /^-/
        return amount.to_f
      else
        return amount.to_f * -1
      end
    end

    def get_description(description)
      description = description.gsub(/(JAN|FEB|MAR|APR|JUN|JUL|AUG|SEP|OCT|NOV|DEC)[0-9]{2}/, '')
      return description.gsub(/@[0-9]{2}:[0-9]{2}/, '')
    end

    def open_csv(filename, account=nil)
      transactions = []
      CSV.open(filename, "r", ';') do |row|
        if row[3] != nil
          transaction = Transaction.new
          transaction.account = account if account != nil
          transaction.description = get_description(row[3])
          transaction.location = Location.create(get_location(transaction.description))
          transaction.payee = Payee.create(get_payee(transaction.description))
          transaction.payee.transactions << transaction

          if row[6] != nil
            category = Category.create(row[6]) 
            transaction.payee.categories << category
            category.payees << transaction.payee
          end

          transaction.date = Date.strptime(row[0], '%d/%m/%Y')
          transaction.amount = row[5].to_i
          transactions << transaction
        end
      end
      return transactions
    end

    def open_xhb(filename)
      transactions = []
      File.open(filename) do |file|
        doc = Hpricot.XML(file)
        accounts = []
        (doc/:account).each { |account_element|
          account = Account.create(account_element['name'], account_element['number'])
          accounts << { "account" => account, "xhb_id" => account_element['id'] }
        }
        (doc/:ope).each { |transaction_element|
          account = nil
          accounts.each { |account_entry|
            if account_entry["xhb_id"] == transaction_element["account"]
              account = account_entry["account"]
            end
          }
          transaction = Transaction.new
          transaction.account = account if account != nil          
          transaction.amount = transaction_element['amount']
          
          transactions << transaction
        }
      end
      return transactions
    end

    def open_qif(filename, account = nil)
      transactions = []
      File.open(filename) do |file|
        transaction = nil
        while content = file.gets
          if content =~ /^D/
            # Date, so new transaction
            transactions << transaction if transaction != nil
            transaction = Transaction.new
            transaction.account = account if account != nil
            transaction.date = Date.strptime(content[1..content.length], '%d/%m/%Y')
          elsif content =~ /^T/
            transaction.amount = get_amount(content[1..content.length])
          elsif content =~ /^P/
            transaction.payee = Payee.create(get_payee(content[1..content.length]))
            transaction.payee.transactions << transaction
          elsif content =~ /^\^/
            # Ignore lines beginning with ^
          else
            puts "I dunno what #{content} means."
          end
        end
      end
      return transactions
    end

    def open(filename)
      transactions = []
      account = nil
      File.open(filename) do |file|
        while content = file.gets
          # match = content.match(Parser::CREDIT_LIMIT_REGEXP)
          # if match
          #   puts match.inspect
          # end
          match = content.match(Parser::ACCOUNT_REGEXP)
          if match
            puts content
            account = Account.create(match[1], match[2])
          end
          if content =~ Parser::STATEMENT_LINE_REGEXP
            match = content.match(Parser::STATEMENT_LINE_REGEXP)
            if match
              transaction = Transaction.new
              transaction.description = match[3].gsub(/\s+$/,'')
              transaction.location = Location.create(get_location(transaction.description))
              transaction.payee = Payee.create(get_payee(transaction.description))
              transaction.payee.transactions << transaction
              transaction.date = Date.strptime(match[2], '%d %b %y')
              transaction.received = Date.strptime(match[1], '%d %b %y')
              transaction.amount = get_amount(match[4])
              transaction.account = account if account != nil
              #puts transaction.inspect
            else
              puts "Unable to parse #{content}"
            end          
          end
        end
      end
      return transactions
    end
  end

  class Account
    attr_accessor :name
    attr_accessor :number
    attr_accessor :credit_limit
    
    @@accounts = []
    def Account.create(name, number)
      name = name.strip
      number = number.gsub(/ /, '')
      account = Account.find_by_name_and_number(name, number)
      if account == nil
        account = Account.new
        account.name = name
        account.number = number
        @@accounts << account
      end
      return account
    end

    def Account.find_by_name_and_number(name, number)
      @@accounts.each { |account|
        return account if account.name == name and account.number == number
      }
      return nil
    end

    def Account.all
      return @@accounts
    end
  end

  class Location
    attr_accessor :name
    attr_accessor :payees

    def initialize(name)
      @name = name
    end

    @@locations = []

    def Location.create(name)
      location = Location.find_by_name name
      if location == nil
        location = Location.new(name)
        @@locations << location
      end
      return location
    end

    def Location.find_by_name(name)
      @@locations.each {|location|
        return location if location.name == name
      }
      return nil
    end

    def Location.all
      return @@locations
    end
  end
  
  class Payee
    attr_accessor :transactions
    attr_accessor :categories
    attr_accessor :name

    def initialize(name)
      @name = name
      @transactions = []
      @categories = []
    end

    @@payees = []
    @@filters = []
    def Payee.create(name)
      payee = Payee.find_by_name name
      if payee == nil
        payee = Payee.new(name) 
        @@payees << payee
      end
      return payee
    end

    def Payee.find_by_name(name)
      @@payees.each { |payee|
        return payee if payee.name == name
      }
      return nil
    end      
    
    def Payee.load_filters(filename)
      @@filters = YAML.load_file(filename)
    end

    def Payee.add_categories(payee)
      @@filters.each { |filter|
        if payee.name =~ filter[:expression]
          category = Category.create(filter[:category])
          payee.categories << category
          category.payees << payee
        end
      }    
    end

    def Payee.categorize_all
      @@payees.each { |payee|
        Payee.add_categories(payee)
      }
    end

    def Payee.all
      return @@payees
    end
  end

  class Category
    attr_accessor :name
    attr_accessor :payees
    
    def initialize(name)
      @name = name
      @payees = []
    end
    
    def transactions
      transactions = []
      @payees.each { |payee|
        transactions = transactions + payee.transactions
      }
      return transactions
    end
    
    def total_amount
      total = 0
      self.transactions.each { |transaction|
        total += transaction.amount
      }
      return total
    end
    
    def total_negative
      total = 0
      self.transactions.each { |transaction|
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
      category = Category.get_by_name name
      if category == nil
        category = Category.new(name)
        @@categories << category
      end
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
  
  class Transaction
    attr_accessor :received
    attr_accessor :date
    attr_accessor :description
    attr_accessor :amount
    attr_accessor :location
    attr_accessor :payee
    attr_accessor :account
  end

  class Graph
    def Graph.category_piechart(filename="piechart.png")
      GoogleChart::PieChart.new('680x400', "Analysis of spending",false) do |chart|
        HSBCChart::Category.all.each { |category|
          amount = category.total_negative * -1
          chart.data "#{category.name} (£#{amount})", amount if amount > 0
        }
        
        uri = URI.parse(chart.to_escaped_url)
        Net::HTTP.start(uri.host) { |http|
          resp = http.get("#{uri.path}?#{uri.query}")
          open(filename, "wb") { |file|
            file.write(resp.body)
          }
        }
      end
    end
    def Graph.category_barchart(filename="barchart.png")
      colours=['660000', '006600', '000066', '660033', '336600', '003366', '660066', '666600', '006666']
      GoogleChart::BarChart.new('680x400', "Analysis of spending", :vertical, false) do |chart|
        colour_index = 0
        # Sort all the categories by their total negative transactions
        categories = Category.all.sort { |x,y| x.total_negative <=> y.total_negative}
        categories.each { |category|
          amount = category.total_negative * -1
          chart.data "#{category.name} (£#{amount})", [amount], colours[colour_index] if amount > 0
          colour_index = colour_index + 1
        }
        
        uri = URI.parse(chart.to_escaped_url)
        Net::HTTP.start(uri.host) { |http|
          resp = http.get("#{uri.path}?#{uri.query}")
          open(filename, "wb") { |file|
            file.write(resp.body)
          }
        }
      end
    end
  end

  class Statement
    def Statement.categories(filename="categories.html")
      mab = Markaby::Builder.new
      mab.html do
        head { title "Category Summary" }
        body do
          h1 "Category Summary"
          ul do
            categories = HSBCChart::Category.all.sort { |x,y| x.total_negative <=> y.total_negative}
            categories.each { |category|
              amount = category.total_negative * -1
              li "#{category.name} #{amount}"
              ul do
                category.transactions.each { |transaction|
                  li "#{transaction.date} #{transaction.amount} #{transaction.description}"
                }
              end
            }
          end
        end
      end

      File.open(filename, "w") do |file|
        file.write(mab.to_s)
      end
    end
  end
end

parser = HSBCChart::Parser.new
transactions=[]
 # Dir.foreach("statements") { |filename|
 #   if filename =~ /.*\.txt$/
 #     transactions = transactions + parser.open("statements/#{filename}")
 #   end
 # }

Dir.foreach("bankaccount") { |filename|
   if filename =~ /.*\.csv$/
     transactions = transactions + parser.open_csv("bankaccount/#{filename}")
   end
 }

# Dir.foreach("bankaccount") { |filename|
#   if filename =~ /.*\.qif$/
#     transactions = transactions + parser.open_qif("bankaccount/#{filename}")
#   end
# }

HSBCChart::Account.all.each { |account|
puts account.inspect
}

transactions = parser.open_xhb("bankaccount/homebank.xhb")

HSBCChart::Payee.load_filters("filters.yaml")
HSBCChart::Payee.categorize_all

HSBCChart::Graph.category_barchart
HSBCChart::Graph.category_piechart

HSBCChart::Payee.all.each {|payee|
  puts "Payee: #{payee.name}"
  payee.transactions.each { |transaction|
    puts "   #{transaction.date} #{transaction.description}"
  }
}

HSBCChart::Location.all.each {|location|
  puts "Location #{location.name}"
}

# HSBCChart::Category.all.each { |category|
#   #puts "Category #{category.name}"
#   puts "#{category.name} #{category.transactions.length} #{category.total_amount}"
# }

HSBCChart::Statement.categories
