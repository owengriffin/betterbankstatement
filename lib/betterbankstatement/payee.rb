
module BetterBankStatement
  class Payee
    attr_accessor :transactions
    attr_accessor :categories
    attr_accessor :name

    def initialize(name)
      @name = name
      @transactions = []
      @categories = []
    end

    def total
      total = 0
      self.transactions.each { |transaction|
        total += transaction.amount
      }
      return total
    end

    def total_credit
      total = 0
      self.transactions.each { |transaction|
        total += transaction.amount if transaction.amount > 0
      }
      return total
    end

    def debit_between(from, to)
      total = 0
      self.transactions.each { |transaction|
        total += transaction.amount if transaction.amount < 0 and transaction.date <= to and transaction.date > from
      }
      return total * -1
    end

    def credit_between(from, to)
      total = 0
      self.transactions.each { |transaction|
        total += transaction.amount if transaction.amount > 0 and transaction.date <= to and transaction.date > from
      }
      return total * -1
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

    # Return a list of Payees from the specified list which have transactions between 2 dates
    def Payee.date_range(list, from, to)
      payees = []
      list.each { |payee|
        transactions = payee.transactions.clone.delete_if { |transaction| transaction.date < from or transaction.date > to }
        payees << payee if transactions.length > 0
      }
      return payees
    end
  end
end
