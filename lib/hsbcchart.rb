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
require 'stylish'
require 'json'

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

    def get_amount(amount, invert=false)
      if amount =~ /^[0-9\.]+CR$/
        return amount[0...amount.length-2].to_f
      else
        return invert ? amount.to_f * -1 : amount.to_f
      end
    end

    def strip_datetime(description)
      description = description.gsub(/(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)[0-9]{2}/, '')
      return description.gsub(/@[0-9]{2}:[0-9]{2}/, '')
    end

    def open_csv(filename, account=nil)
      transactions = []
      CSV.open(filename, "r", ';') do |row|
        if row[3] != nil
          transaction = Transaction.new
          transaction.account = account if account != nil
          transaction.description = strip_datetime(row[3])
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
            transaction.description = strip_datetime(content[1..content.length])
            transaction.payee = Payee.create(get_payee(transaction.description))
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
              transaction.amount = get_amount(match[4], true)
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

    def total_credit
      total = 0
      self.transactions.each { |transaction|
        total += transaction.amount if transaction.amount > 0
      }
      puts "Total credit for #{@name} = #{total}"
      return total
    end
    
    def total_debit
      total = 0
      self.transactions.each { |transaction|
        total += transaction.amount if transaction.amount < 0
      }
      return total * -1
    end

    def transactions_between(from, to)
      transactions = []
      @transactions.each { |transaction|
        if transaction.date != nil and transaction.date > from and transaction.date <= to
          #puts "#{transaction.date} is between #{from} and #{to}"
          transactions << transaction
        end
      }
      return transactions
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

    def Payee.after(date, set=nil)
      payees = []
      set = @@payees if set == nil
      set.each { |payee|
        transactions = payee.transactions.clone.delete_if { |transaction| transaction.date < date }
        payees << payee if transactions.length > 0
      }
      return payees
    end

    def Payee.last_month
      now = DateTime.now
      return Payee.after(Date.new(now.year, now.month - 1, now.day))
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

    # Return the total amount of money for this Category on a
    # particular date
    def total_between(from, to)
      total = 0
      @payees.each { |payee|
        payee.transactions_between(from, to).each {|transaction|
          total = total + transaction.amount
        }
      }
      puts "Total between #{from} and #{to} is #{total}"
      return total;
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

    def Category.after(date)
      categories = []
      @@categories.each { |category|
        payees = Payee.after(date, category.payees) 
        categories << category if payees.length > 0
      }
      return categories
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

    def Graph.safe_name(name)
      return name.gsub(/ & /, 'and')
    end

    def Graph.category_timeline2
      chart = Hash.new
#       chart["title"]={'text' => 'Test'}
# chart["elements"]={"type" => "hbar", "values" => [{"right"=>10},{"right"=>15},{"left"=>13,"right"=>17}]}
# chart["x_axis"]={"min"=>0, "max"=>20, "offset"=>0, "labels"=> ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v"] }
# chart["y_axis"]={ "stroke"=> 14,
#     "tick_length"=>30,
#     "colour"=>      "#d09090",
#     "grid_colour"=> "#00ff00",
#     "offset"=>      1,
#   "labels"=>      ["slashdot.org","digg.com","reddit.com"]}

      chart["elements"] = []

      chart["title"] = { "text"=> "Area Chart" }



      now = DateTime.now
      from = Date.new(now.year, now.month - 1, now.day)

      min = 0
      max = 0
      index = 0
      colours=['660000', '006600', '000066', '660033', '336600', '003366', '660066', '666600', '006666', '660000', '006600', '000066', '660033', '336600', '003366', '660066', '666600', '006666']
      Category.all.each { |category|
        if category.total_between(from, now) != 0
          data = []
          (from..now).each { |date| 
            
            total = category.total_between(date , date + 1 ) 
            #puts "category.total_between #{date} = #{total}"
            data << total * -1
          }
          puts data.inspect
          data.each { |d| 
            if d > max
              max = d
            end
            if d < min
              min = d
            end
          }
          chart["elements"].push({ "type"=> "line", "width"=> 1, "colour"=> '#' + colours[index], "values" => data, "text" => category.name})          
          index = index + 1
        end
      }
      labels = []
      (from..now).each { |date|
        labels << date.strftime('%d-%m') #date.strftime('%d')
      }
      puts labels.inspect
      chart["x_axis"] = { "labels"=> { "labels" => labels, "rotate" => 270 } , "steps"=> 7, "stoke" => 1 } 
      chart["x_legend"] = { "text" => "#{from.strftime('%d-%m-%Y')} to #{now.strftime('%d-%m-%Y')}", "style" => {"font-size" => "20px", "color" => "#778877" } }
      chart["y_axis"] = { "min"=> min, "max"=> max, "steps"=> 10, "labels"=> nil, "offset"=> 0 }
      return chart.to_json
    end

    def Graph.category_timeline()
      now = DateTime.now
      from = Date.new(now.year, now.month - 1, now.day)

#       labels = []
#       (from..now).each { |date|
#         labels << date
#       }

# chart = Hash.new
# chart["title"]={'text' => 'Test'}
# chart["elements"]={"type" => "hbar", "values" => [{"right"=>10},{"right"=>15},{"left"=>13,"right"=>17}]}
# chart["x_axis"]={"min"=>0, "max"=>(from..now).length, "offset"=>0, "labels"=> labels }
# chart["y_axis"]={ "stroke"=> 14,
#     "tick_length"=>30,
#     "colour"=>      "#d09090",
#     "grid_colour"=> "#00ff00",
#     "offset"=>      1,
#   "labels"=>      ["slashdot.org","digg.com","reddit.com"]}


      # Calculate which categories to plot in the timeline



      chart = GoogleChart::LineChart.new('320x200', "Line Chart", false)
      min = 0
      max = 0
      Category.all.each { |category|
        if category.total_between(from, now) != 0
          data = []
          (from..now).each {|date| 
            total = category.total_between(date, date + (60*60*24)) 
            puts "category.total_between = #{total}"
            data << total *-1
          }
          puts data.inspect
          data.each { |d| 
            if d > max
              max = d
            end
            if d < min
              min = d
            end
          }
          chart.data category.name, data
        end
      }
      chart.axis :y, :range => [min,max], :color => 'ff00ff', :font_size => 16, :alignment => :center
      chart.axis :x, :range => [from, now], :color => '00ffff', :font_size => 16, :alignment => :center

      puts chart.to_escaped_url
      
      uri = URI.parse(chart.to_escaped_url)
      Net::HTTP.start(uri.host) { |http|
        resp = http.get("#{uri.path}?#{uri.query}")
        open(filename, "wb") { |file|
          file.write(resp.body)
        }
      }
    end

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
    def Graph.creditors(filename="piechart.png", date=nil)
      payees = []
      if date == nil
        payees = Payee.all
      else
        payees = Payee.after(date)
      end
      puts payees
      payees = payees.clone.delete_if {|payee| payee.total_credit <= 0 }
      puts payees
      GoogleChart::PieChart.new('680x400', "Creditors",false) do |chart|
        payees.each { |payee|
          amount = payee.total_credit
          puts "#{payee.name} (£#{amount})"
          chart.data "#{Graph.safe_name(payee.name)} (£#{amount})", amount if amount > 0
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
    def Graph.debitors(filename="piechart.png", date=nil)
      payees = []
      if date == nil
        payees = Payee.all
      else
        payees = Payee.after(date)
      end
      puts payees
      payees = payees.clone.delete_if {|payee| payee.total_debit <= 0 }
      puts payees
      GoogleChart::PieChart.new('680x400', "Debitors",false) do |chart|
        payees.each { |payee|
          amount = payee.total_debit
          puts "#{payee.name} (£#{amount})"
          chart.data "#{Graph.safe_name(payee.name)} (£#{amount})", amount if amount > 0
        }
        puts chart.to_url
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

    def Statement.css
      style = Stylish.generate do
        p :line_height => 1.5
        a :text_transform => "uppercase"
        rule "ul li" do
          span :padding => 1.5
        end
        rule "ul li span.date", :font_size => "0.8em"
      end
      return style.to_s
    end

    def Statement.payees(filename="payees.html", from=nil)
      if from == nil
        from = DateTime.now
        from = Date.new(from.year, from.month - 1, from.day)
      end
      Graph.creditors("creditors.png", from)
      Graph.debitors("debitors.png", from)
      mab = Markaby::Builder.new
      mab.html do
        head do
          title "Category Summary" 
          style :type => "text/css" do
            Statement.css
          end
        end
        body do
          h1 "Payee Summary"
          img :src => "creditors.png"
          img :src => "debitors.png"
          ul do
            payees = HSBCChart::Payee.after(from)
            payees.each { |payee|
              li payee.name
              ul do
                transactions = payee.transactions.clone.delete_if { |x| x.date < from }
                transactions.each { |transaction|
                  li do
                    span.date transaction.date
                    span.amount "£#{transaction.amount}"
                    span.description transaction.description
                  end
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

    def Statement.categories(filename="categories.html", from=nil)
      if from == nil
        from = DateTime.now
        from = Date.new(from.year, from.month - 1, from.day)
      end

      mab = Markaby::Builder.new
      mab.html do
        head { title "Category Summary" }
        body do
          h1 "Category Summary"
          script :type => "text/javascript", :src => "json.js"
          script :type => "text/javascript", :src => "swfobject.js"
          script :type => "text/javascript" do
            'swfobject.embedSWF("open-flash-chart.swf", "my_chart", "650", "500", "9.0.0");'
          end
          script :type => "text/javascript" do
            '
function ofc_ready()
{
	//alert("ofc_ready");
}

function findSWF(movieName) {
  if (navigator.appName.indexOf("Microsoft")!= -1) {
    return window[movieName];
  } else {
    return document[movieName];
  }
}
'
          end
          script :type => "text/javascript" do
            'function open_flash_chart_data() {
//alert("Reading data"); 
var data = ' + HSBCChart::Graph.category_timeline2 + ';
var retval =  JSON.stringify(data);
//alert(retval);
return retval;
 }'
          end
          div :id => "my_chart"
          ul do
            categories = HSBCChart::Category.after(from).sort { |x,y| x.total_negative <=> y.total_negative}
            categories.each { |category|
              amount = category.total_negative * -1
              li "#{category.name} #{amount}"
              ul do
                transactions = category.transactions.clone.delete_if { |x| x.date < from }
                transactions.each { |transaction|
                  li do
                    span transaction.date
                    span transaction.amount
                    span transaction.description
                  end
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

