
module BetterBankStatement
  class Transaction
    attr_accessor :received
    attr_accessor :date
    attr_accessor :description
    attr_accessor :amount
    attr_accessor :location
    attr_accessor :payee
    attr_accessor :account

    @@transactions = []

    def Transaction.create
      transaction = Transaction.new
      @@transactions << transaction
      return transaction
    end

    # Return the total number of transactions between two dates
    def Transaction.total_between(from, to)
      total = 0
      @@transactions.each { |transaction|
        total = total + 1 if transaction.date > from and transaction.date < to
      }
      return total
    end
  end
end
