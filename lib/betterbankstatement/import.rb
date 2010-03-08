# -*- coding: utf-8 -*-

module BetterBankStatement
  class Import
    def self.parse_currency(amount, invert=false)
      if amount =~ /^[0-9\.]+CR$/
        return amount[0...amount.length-2].to_f
      else
        return invert ? amount.to_f * -1 : amount.to_f
      end
    end

    def self.qif(str)
      duplicate_count = 0
      transaction_count = 0
      transaction = nil 
      str.each_line do |content|
        if content =~ /^D/
          # Line content is a date. 
          # Create a new transaction
          transaction = Transaction.new(:date => Date.strptime(content[1..content.length], '%d/%m/%Y'))
        elsif content =~ /^T/
          # Line content is an amount
          transaction.amount = self.parse_currency(content[1..content.length])
        elsif content =~ /^P/
          # Line contains a description
          transaction.description = content[1..content.length - 2]
        elsif content =~ /^\^/
          if transaction != nil
            # Check to see if the transaction already exists
            d = Date.strptime("#{transaction.date.year}/#{transaction.date.month}/#{transaction.date.day}", '%Y/%m/%d')
            count = Transaction.count(:amount => transaction.amount, 
                                      :description => transaction.description,
                                      :date => ((d - 1)..(d+1)))
            if count == 0
              # Persist the transaction
              transaction.save
              transaction_count = transaction_count + 1
            else
              duplicate_count = duplicate_count + 1
            end
          end
        elsif content =~ /^!/
          # Line content indicates the type of document
        else
          BetterBankStatement.log.debug "Unrecognized line content '#{content}' in QIF."
        end
      end
      return {:no_imported => transaction_count, :no_duplicates => duplicate_count}
    end

    def self.qif_file(filename)
      return self.qif(File.readlines(filename).join)
    end

    def self.pdf(filename)
      # Use `pdf2text -layout ` command
    end

    def self.pdf_text(str)
      transaction_count = 0
      duplicate_count = 0
      str.each_line do |content|
        match = content.match(/^\s*([0-9]{2}\s+[a-z]{3}\s+[0-9]{2})\s+([0-9]{2}\s+[a-z]{3}\s+[0-9]{2})\s+(.+)\s+([0-9\.]+(?:CR)?)\s*$/mi)
        if match
          transaction = Transaction.new
          transaction.description = match[3].gsub(/\s+$/,'')
          transaction.date = Date.strptime(match[2], '%d %b %y')
          # transaction.received = Date.strptime(match[1], '%d %b %y')
          transaction.amount = self.parse_currency(match[4], true)
          transaction.save
          transaction_count = transaction_count + 1
        else
          BetterBankStatement.log.debug "Unrecognized line content '#{content}' in PDF."
        end          
      end
      return {:no_imported => transaction_count, :no_duplicates => duplicate_count}
    end

    def self.pdf_textfile(filename)
      return self.pdf_text(File.readlines(filename).join)
    end
  end
end
