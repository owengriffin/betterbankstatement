
module HSBCChart
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

    def Category.date_range(list, from, to)
      categories = []
      list.each { |category|
        payees = Payee.date_range(category.payees, from, to)
        categories << category if payees.length > 0
      }
      return categories
    end
  end
end
