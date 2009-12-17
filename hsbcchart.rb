require 'lib/hsbcchart.rb'
require 'lib/openstreetmap.rb'

# puts OpenStreetMap::Geocoder.find_location('Reading').inspect

parser = HSBCChart::Parser.new
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

# HSBCChart::Account.all.each { |account|
# puts account.inspect
# }

#transactions = parser.open_xhb("bankaccount/homebank.xhb")

HSBCChart::Payee.load_filters("filters.yaml")
HSBCChart::Payee.categorize_all

# HSBCChart::Graph.category_barchart
# HSBCChart::Graph.category_piechart

# HSBCChart::Payee.all.each {|payee|
#   puts "Payee: #{payee.name}"
#   payee.transactions.each { |transaction|
#     puts "   #{transaction.date} #{transaction.description}"
#   }
# }

# HSBCChart::Location.all.each {|location|
#   puts "Location #{location.name}"
# }

HSBCChart::Category.all.each { |category|
  puts "#{category.name} #{category.transactions.length} #{category.total_amount}"
}

HSBCChart::Statement.generate
