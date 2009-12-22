require './lib/betterbankstatement.rb'
require 'lib/openstreetmap.rb'

# puts OpenStreetMap::Geocoder.find_location('Reading').inspect

parser = BetterBankStatement::Parser.new
transactions=[]
Dir.foreach("statements") { |filename|
  if filename =~ /.*\.txt$/
    transactions = transactions + parser.open("statements/#{filename}")
  end
}

# Dir.foreach("bankaccount") { |filename|
#    if filename =~ /.*\.csv$/
#      transactions = transactions + parser.open_csv("bankaccount/#{filename}")
#    end
#  }

Dir.foreach("bankaccount") { |filename|
  if filename =~ /.*\.qif$/
    transactions = transactions + parser.open_qif("bankaccount/#{filename}")
  end
}

# BetterBankStatement::Account.all.each { |account|
# puts account.inspect
# }

#transactions = parser.open_xhb("bankaccount/homebank.xhb")

BetterBankStatement::Payee.load_filters("filters.yaml")
BetterBankStatement::Payee.categorize_all

# BetterBankStatement::Graph.category_barchart
# BetterBankStatement::Graph.category_piechart

# BetterBankStatement::Payee.all.each {|payee|
#   puts "Payee: #{payee.name}"
#   payee.transactions.each { |transaction|
#     puts "   #{transaction.date} #{transaction.description}"
#   }
# }

# BetterBankStatement::Location.all.each {|location|
#   puts "Location #{location.name}"
# }

BetterBankStatement::Category.all.each { |category|
  puts "#{category.name} #{category.transactions.length} #{category.total_amount}"
}

BetterBankStatement::Statement.generate
