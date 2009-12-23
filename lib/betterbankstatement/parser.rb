# -*- coding: utf-8 -*-

module BetterBankStatement
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
          transaction = Transaction.create
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
          transaction = Transaction.create
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
            transaction = Transaction.create
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
              transaction = Transaction.create
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

end
