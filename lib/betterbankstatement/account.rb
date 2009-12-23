
module BetterBankStatement
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
end
