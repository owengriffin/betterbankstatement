
module BetterBankStatement

  class Transaction
    include DataMapper::Resource
    property :id, Serial
    property :recieved, DateTime
    property :date, DateTime
    property :description, String
    property :amount, Integer
    has n, :categories, :through => Resource

    def category
      self.categories.first
    end

    def category=(category)
      self.categories << category
    end
     
    # Apply all the filters to this transaction if they match
    def filter
      Filter.all.each { |filter|
        regexp = Regexp.new(filter.expression)
        if regexp.match(self.description)
          BetterBankStatement.log.debug "Placing #{self.description} in #{filter.category.name}"
          self.categories << filter.category
          self.save
          filter.category.save
        end
      } 
    end

    # Filter all of the available transactions
    def self.filter
      Transaction.all.each do |transaction|
        transaction.filter
      end
    end

    # Return the earliest transaction
    def self.earliest
      return Transaction.first(:order => [:date.asc])
    end

    # Return the latest transaction
    def self.latest
      return Transaction.first(:order => [:date.desc])
    end
  end
end
