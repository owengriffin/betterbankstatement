get '/transactions' do
  session[:title] = "Transactions"
  earliest = BetterBankStatement::Transaction.earliest
  latest = BetterBankStatement::Transaction.latest
  @global_date_range = (earliest.date..latest.date) if earliest != nil and latest != nil
  haml :transactions
end

get '/transactions/:year/:month' do
  earliest = BetterBankStatement::Transaction.earliest
  latest = BetterBankStatement::Transaction.latest
  @global_date_range = (earliest.date..latest.date) if earliest != nil and latest != nil
  if params[:year] and params[:month]
    year = params["year"].to_i
    month = params["month"].to_i
    from = Chronic.parse("#{year}/#{month}/01")
    to = Chronic.parse("#{year}/#{month}/#{Date.days_in_month(month)}")
    @date_range = (from.to_date..to.to_date)
    @transactions = BetterBankStatement::Transaction.all(:order => [:date.asc], :date => (from..to))
  end
  haml :transactions
end

get '/transactions/:year/:month/piechart/debit' do
  year = params["year"].to_i
  month = params["month"].to_i
  from = Chronic.parse("#{year}/#{month}/01")
  to = Chronic.parse("#{year}/#{month}/#{Date.days_in_month(month)}")
  values = []
  sum = 0.0
  BetterBankStatement::Category.all.each do |category|
    sum = sum + category.debit((from..to))
  end
  sum = sum * -1
  BetterBankStatement::Category.all.each do |category|
    value = (category.debit((from..to)) * -1 / sum) * 100
    if value > 0
      values.push ({ "value" => value,
        "label" => category.name
      })
    end
  end
  chart = Hash.new
  chart["elements"] = []
  chart["elements"].push({ "type" => "pie",
                           "alpha" => 0.6,
                           "start-angle" => 35,
                           "animate" => [ { "type" => "fade" } ],
                           "tip" => "#val# of #total#",
                           "colours" => [  "#222222", "#DDDDDD" ],
                           "values" => values })
  chart["title"] = { "text" => "Debit" }
  chart["bg_colour"] = "#FFFFFF"
  content_type :json
  chart.to_json
end

get '/transactions/:year/:month/piechart/credit' do
  year = params["year"].to_i
  month = params["month"].to_i
  from = Chronic.parse("#{year}/#{month}/01")
  to = Chronic.parse("#{year}/#{month}/#{Date.days_in_month(month)}")
  values = []
  sum = 0.0
  BetterBankStatement::Category.all.each do |category|
    sum = sum + category.credit((from..to))
  end
  BetterBankStatement::Category.all.each do |category|
    value = (category.credit((from..to)) / sum) * 100
    if value > 0
      values.push ({ "value" => value,
        "label" => category.name
      })
    end
  end
  chart = Hash.new
  chart["elements"] = []
  chart["elements"].push({ "type" => "pie",
                           "alpha" => 0.6,
                           "start-angle" => 35,
                           "animate" => [ { "type" => "fade" } ],
                           "tip" => "#val# of #total#",
                           "colours" => [  "#222222", "#DDDDDD" ],
                           "values" => values })
  chart["title"] = { "text" => "Credit" }
#  chart["x_axis"] = nil  
  chart["bg_colour"] = "#FFFFFF"
  content_type :json
  chart.to_json
end
