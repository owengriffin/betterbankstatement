
module BetterBankStatement
  class Category
    include DataMapper::Resource
    property :id, Serial
    property :name, String
    has n, :transactions, :through => Resource

    def self.create_or_get(attr)
      category = self.first(attr)
      category = Category.new(attr) if category == nil
      return category
    end

    # Return the total amount of money spent in this category
    def total_amount(range = nil)
      return (range == nil ? self.transactions : self.transactions.all(:date => range)).sum(:amount)
    end
    
    # Return the cummulative total of the amount spent on each transaction
    # in this category.
    def debit(range = nil)
      debit = (range == nil ? self.transactions : self.transactions.all(:date => range)).all(:amount.lt => 0).sum(:amount)
      debit == nil ? 0.0 : debit
    end

    # Return the cummulative total of the amount recieved on each transaction
    # in this category
    def credit(range = nil)
      credit = (range == nil ? self.transactions : self.transactions.all(:date => range)).all(:amount.gt => 0).sum(:amount)
      credit == nil ? 0.0 : credit
    end

    # Return the average amount in a transaction for this Category
    def average(range = nil)
      return (range == nil ? self.transactions : self.transactions.all(:date => range)).avg(:amount)
    end

    # Return the earliest transaction
    def earliest
      return self.transactions.first(:order => [:date.asc])
    end

    # Return the latest transaction
    def latest
      return self.transactions.first(:order => [:date.desc])
    end

    # Return the total number of transactions
    def total_transactions
      return self.transactions.count
    end

    # Return the average amount spent in this category per month
    def monthly_average
      if self.total_transactions == 0
        return 0
      end
      # Use the latest transaction date unless the date is less than today. This
      # will ignore incompleted dates
      latest_date = self.latest.date
      latest_date = Date.today if latest_date < Date.today
      # Ensure that we start counting the average from the earliest transaction
      from = self.earliest.date
      month = from.month
      # Ensure that we calculate from the first day of the month
      from = Date.new(from.year, month, 1)
      to = Date.new(from.year, month, Date.days_in_month(month))
      sum = 0
      total = 0
      until to.year == latest_date.year and to.month >= latest_date.month
        sum = sum + self.average(from..to)
        total = total + 1
        from = to + 1
        to = Date.jump_forward_month(to)
      end
      return sum / total
    end
  end
end
